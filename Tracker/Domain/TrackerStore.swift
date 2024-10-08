//
//  TrackerStore.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 28.03.2024.
//

import CoreData
import UIKit

private enum TrackerStoreError: Error {
    case decodingTrackerError
    case otherError
}

enum trackerStoreFiltrationType {
    case all
    case uncompleted
    case completed
}

protocol TrackerStoreDelegate: AnyObject {
    func didChangeData(in store: TrackerStore)
}

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
    
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Private properties
    private var trackerRecordStore = TrackerRecordStore.shared
    private var currentDay: Int = 0
    
    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }
    
    private var context: NSManagedObjectContext? {
        appDelegate?.persistentContainer.viewContext
    }
    
    private var categories = [TrackerCategory]()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>? = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true)
        ]
        guard let context else { return nil }
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil
        )
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            print("PerformFetchError: \(error)")
        }
        
        return controller
    }()
    
    // MARK: - Initializers
    private override init() {
        ValueTransformer.setValueTransformer(
            UIColorTransformer(),
            forName: NSValueTransformerName("UIColorTransformer")
        )
    }
    
    // MARK: - Public methods
    func getTrackerCategories(_ day: Int, currentDate: Date, filtrationType: trackerStoreFiltrationType) throws -> [TrackerCategory] {
        self.currentDay = day
        
        guard let objects = fetchedResultsController?.fetchedObjects else {
            throw TrackerStoreError.otherError
        }
        
        // Group trackers by category title
        let categories2 = Dictionary(grouping: objects, by: { $0.category?.title })
        
        var categories = [TrackerCategory]()
        
        // Filter pinned trackers based on filtrationType
        var filteredPinnedTrackers: [TrackerCoreData] = []
        for tracker in objects where tracker.pin {
            switch filtrationType {
            case .all:
                filteredPinnedTrackers.append(tracker)
            case .completed:
                if let id = tracker.id, !records(for: id, at: currentDate).isEmpty {
                    filteredPinnedTrackers.append(tracker)
                }
            case .uncompleted:
                if let id = tracker.id, records(for: id, at: currentDate).isEmpty {
                    filteredPinnedTrackers.append(tracker)
                }
            }
        }
        
        // Process remaining categories and trackers
        for (key, trackersCoreData) in categories2 where key != "Закрепленные" {
            var filteredTrackers = trackersCoreData.filter { tracker -> Bool in
                // Pinned trackers go to the pinned category (already filtered)
                return !tracker.pin
            }
            
            switch filtrationType {
            case .all:
                break
            case .completed:
                filteredTrackers = filteredTrackers.filter { trackerCoreData in
                    if let id = trackerCoreData.id, !records(for: id, at: currentDate).isEmpty {
                        return true
                    }
                    return false
                }
            case .uncompleted:
                filteredTrackers = filteredTrackers.filter { trackerCoreData in
                    if let id = trackerCoreData.id, records(for: id, at: currentDate).isEmpty {
                        return true
                    }
                    return false
                }
            }
            
            if let key = key {
                let category = TrackerCategory(
                    title: key,
                    trackers: try trackersCoreDataToTrackers(from: filteredTrackers, currentDate: currentDate)
                )
                categories.append(category)
            } else {
                throw TrackerStoreError.otherError
            }
        }
        
        // 3. Add filtered pinned category (if any) as the first category
        if !filteredPinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(
                title: "Закрепленные",
                trackers: try trackersCoreDataToTrackers(from: filteredPinnedTrackers, currentDate: currentDate)
            )
            categories.insert(pinnedCategory, at: 0)
        }
        
        categories = filterEmptySections(categories)
        
        return categories
    }
    
    private func records(for trackerID: UUID, at date: Date) -> [TrackerRecord] {
        let date = date.onlyDate
        do {
            let records = try trackerRecordStore.fetchTrackerRecord()
            let filteredRecords = Array(records)
            
            return filteredRecords.filter { $0.id == trackerID && $0.date == date }
        } catch {
            return []
        }
    }
    
    func updateTrackerPin(trackerId: UUID, isPinned: Bool) throws {
        guard let context else { throw TrackerStoreError.otherError }
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.id), trackerId as CVarArg)
        
        guard let tracker = try context.fetch(fetchRequest).first else {
            throw TrackerStoreError.otherError
        }
        
        tracker.pin = isPinned
        
        try context.save()
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        guard let context else { throw TrackerStoreError.otherError }
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = WeekDay.convertScheduleToString(tracker.schedule ?? nil)
        trackerCoreData.trackerType = TrackerTypes.convertTrackerTypeToString(trackerType: tracker.trackerType)
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        let findCategory = try? context.fetch(fetchRequest)
        let trackerCategory: TrackerCategoryCoreData
        
        if let finded = findCategory?.first {
            trackerCategory = finded
        } else {
            trackerCategory = TrackerCategoryCoreData(context: context)
            trackerCategory.title = category.title
        }
        
        trackerCategory.addToTrackers(trackerCoreData)
        
        appDelegate?.saveContext()
    }
    
    func editTracker(_ tracker: Tracker, id: UUID?, newCategory: String) throws {
        guard let context, let id else { throw TrackerStoreError.otherError }
        
        // Fetch the tracker to edit by UUID
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.id), id as CVarArg)
        
        let trackers = try context.fetch(fetchRequest)
        
        guard let trackerToEdit = trackers.first else {
            throw TrackerStoreError.otherError
        }
        
        // Update tracker properties
        trackerToEdit.title = tracker.title
        trackerToEdit.color = tracker.color
        trackerToEdit.emoji = tracker.emoji
        trackerToEdit.schedule = WeekDay.convertScheduleToString(tracker.schedule ?? nil)
        trackerToEdit.trackerType = TrackerTypes.convertTrackerTypeToString(trackerType: tracker.trackerType)
        
        // Fetch the new category
        let newCategoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        newCategoryFetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), newCategory)
        
        guard let newCategoryCoreData = try context.fetch(newCategoryFetchRequest).first else {
            throw TrackerStoreError.otherError
        }
        
        // Update tracker's category (optional check for existing category)
        if trackerToEdit.category != newCategoryCoreData {
            trackerToEdit.category = newCategoryCoreData
        }
        
        try context.save()
    }
    
    func deleteTracker(with uuid: UUID?) throws {
        guard let context, let uuid else { throw TrackerStoreError.otherError }
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.id), uuid as CVarArg)
        
        let trackers = try context.fetch(fetchRequest)
        
        guard let trackerToDelete = trackers.first else {
            throw TrackerStoreError.otherError
        }
        
        context.delete(trackerToDelete)
        try context.save()
    }
    
    func recognizeTrackerCategory(uuid: UUID) -> String? {
        guard let context else {
            return nil
        }
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.id), uuid as CVarArg)
        
        do {
            let tracker = try context.fetch(fetchRequest).first
            guard let category = tracker?.category else {
                throw TrackerStoreError.otherError
            }
            return category.title
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let color = trackerCoreData.color,
            let emoji = trackerCoreData.emoji,
            let trackerType = trackerCoreData.trackerType
        else { throw TrackerStoreError.decodingTrackerError }
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: WeekDay.getScheduleFromString(daysString: trackerCoreData.schedule ?? ""),
            trackerType: TrackerTypes.getTrackerTypeFromString(string: trackerType),
            pin: trackerCoreData.pin)
    }
    
    func filterCategoriesByWeekDay(selectedWeekDay: Int?) {
        var predicates: [NSPredicate] = []
        
        if let selectedWeekDay {
            let schedulePredicate = NSPredicate(
                format: "%K CONTAINS %@ OR %K == NULL",
                #keyPath(TrackerCoreData.schedule),
                String(selectedWeekDay),
                #keyPath(TrackerCoreData.schedule)
            )
            predicates = [schedulePredicate]
        } else {
            return
        }
        
        fetchedResultsController?.fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Perform fetch error in TrackerStore.filterCategoriesByWeekDay /n ----------- Error: \(error)")
        }
        
    }
    
    // MARK: - Private methods
    private func trackersCoreDataToTrackers(from trackersCoreData: [TrackerCoreData], currentDate: Date) throws -> [Tracker] {
        var array = [Tracker]()
        let date = currentDate.onlyDate ?? Date()
        
        let records = Array(try trackerRecordStore.fetchTrackerRecord())
        
        for i in trackersCoreData {
            array.append(try tracker(from: i))
        }
        
        let filteredArray = filterTrackers(trackers: array, records: records, currentDate: date)
        
        return filteredArray
    }
    
    private func filterTrackers(trackers: [Tracker], records: [TrackerRecord], currentDate: Date) -> [Tracker] {
        let filteredRecords = records.filter { $0.date != currentDate }
        let filteredTrackerIDs = Set(filteredRecords.map { $0.id })
        return trackers.filter { $0.trackerType != TrackerTypes.oneTimeEvent || !filteredTrackerIDs.contains($0.id) }
    }
    
    private func filterEmptySections(_ categories: [TrackerCategory]) -> [TrackerCategory] {
        let filteredCategories = categories.filter { $0.trackers != [] }
        return filteredCategories
    }
    
    private func fetchTrackers() -> [Tracker] {
        return [Tracker]()
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeData(in: self)
    }
}
