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

protocol TrackerStoreDelegate: AnyObject {
    func didChangeData(in store: TrackerStore)
}

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
    
    weak var delegate: TrackerStoreDelegate?
    
    var currentDay: Int = 0
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true)
        ]
        
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
    
    func trackersCoreDataToTrackers(from: [TrackerCoreData]) throws -> [Tracker] {
        var array2 = [Tracker]()
        for i in from {
            array2.append(try tracker(from: i))
        }
        return array2
    }
    
    func getTrackerCategories(_ day: Int) throws -> [TrackerCategory] {
        self.currentDay = day

        guard let objects = fetchedResultsController.fetchedObjects else {
            throw TrackerStoreError.otherError
        }
        
        let categories2 = Dictionary(grouping: objects, by: { $0.category!.title })
        
        categories = [TrackerCategory]()
        
        for i in categories2 {
            let trackerCategory = TrackerCategory(title: i.key!, trackers: try trackersCoreDataToTrackers(from: i.value))
            categories.append(trackerCategory)
        }

        return categories
    }
    
    private override init() {
        ValueTransformer.setValueTransformer(
            UIColorTransformer(),
            forName: NSValueTransformerName("UIColorTransformer")
        )
    }
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    var categories = [TrackerCategory]()
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
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
        
        appDelegate.saveContext()
    }
    
    func fetchTrackers() -> [Tracker] {
        return [Tracker]()
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
            schedule: WeekDay.getScheduleFromString(daysString: "2"),
            trackerType: TrackerTypes.getTrackerTypeFromString(string: trackerType))
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
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Perform fetch error in TrackerStore.filterCategoriesByWeekDay /n ----------- Error: \(error)")
        }

    }
}

// MARK: NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeData(in: self)
    }
}
