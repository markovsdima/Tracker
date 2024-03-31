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
}

protocol TrackerStoreDelegate: AnyObject {
    func didChangeData(in store: TrackerStore)
}

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
    
    weak var delegate: TrackerStoreDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        //let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCategoryCoreData.title),
            cacheName: nil
        )
        controller.delegate = self
        //try? controller.performFetch()
        do {
            try controller.performFetch()
        } catch {
            print("PerformFetchError: \(error)")
        }
        
        return controller
    }()
    
    var allTrackers: [TrackerCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    
    
    private override init() {
        ValueTransformer.setValueTransformer(
            UIColorTransformer(),
            forName: NSValueTransformerName("UIColorTransformer")
        )
    }
    //private let context: NSManagedObjectContext
    
    //    convenience override init() {
    //        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //        self.init(context: context)
    //    }
    
    //    init(context: NSManagedObjectContext) {
    //        self.context = context
    //    }
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    var categories = [TrackerCategory]()
    
//    func createTracker(
//        id: UUID,
//        title: String,
//        color: UIColor,
//        emoji: String,
//        schedule: [WeekDay],
//        trackerType: TrackerTypes
//    ) {
//        guard let trackerEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerCoreData", in: context) else {
//            print("Unable to create trackerEntityDescription with trackerStore")
//            return
//        }
//        let tracker = TrackerCoreData
//    }
    
    private func simpleFetch(with context: NSManagedObjectContext) {
        // Создаём запрос.
        // Указываем, что хотим получить записи Author и ответ привести к типу Author.
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        // Выполняем запрос, используя контекст.
        // В результате получаем массив объектов Author.
        let trackers = try? context.fetch(request)
        // Печатаем в консоль имена и год автора.
        //trackers?.forEach { print("\($0.title) \($0.emoji)") }
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        //TrackerCategoryStore.shared.AddCategory(title: "111")
        //let trackerCategoryCoreData = try TrackerCategoryStore.shared.newCategory(title: "111")
        //print(category!)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = WeekDay.convertScheduleToString(tracker.schedule ?? nil)
        //trackerCoreData.category = trackerCategoryCoreData
        trackerCoreData.trackerType = TrackerTypes.convertTrackerTypeToInt(trackerType: tracker.trackerType)
        
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
        
        //categories = try TrackerCategoryStore.shared.getTrackerCategories()
        
        //print("trackerCoreData ------------- \(trackerCoreData)")
        //print("category ------------- \(category)")
        //simpleFetch(with: context)
    }
    
    func fetchTrackers() -> [Tracker] {
        return [Tracker]()
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let color = trackerCoreData.color,
            let emoji = trackerCoreData.emoji
            //let schedule = trackerCoreData.schedule
            //let trackerType = trackerCoreData.trackerType
        else { throw TrackerStoreError.decodingTrackerError }
        
        let trackerType = trackerCoreData.trackerType
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            //schedule: WeekDay.getScheduleFromString(daysString: schedule),
            schedule: [],
            trackerType: TrackerTypes.getTrackerTypeFromInt(integer16: trackerType))
    }
    
    
    func filterCategoriesByWeekDay(selectedWeekDay: Int?) {
        
        var predicates: [NSPredicate] = []
        
        if let selectedWeekDay {
            let reqularEventPredicate = NSPredicate(
                format: "%K == %@ AND %K CONTAINS %@",
                #keyPath(TrackerCoreData.trackerType),
                TrackerTypes.regularEvent.rawValue,
                #keyPath(TrackerCoreData.schedule),
                String(selectedWeekDay)
            )
            let oneTimeEventPredicate = NSPredicate(
                format: "%K == %@ ",
                #keyPath(TrackerCoreData.trackerType),
                TrackerTypes.oneTimeEvent.rawValue
            )
            predicates = [reqularEventPredicate, oneTimeEventPredicate]
        } else {
            return
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Perform fetch error in TrackerStore.filterCategoriesByWeekDay /n ----------- Error: \(error)")
        }
        
        delegate?.didChangeData(in: self)
        
//    case oneTimeEvent
//    case regularEvent
        
//        filteredCategories = categories.compactMap { category in
//            
//            let filteredTrackers = category.trackers.filter { tracker in
//                guard let schedule = tracker.schedule else {
//                    return true
//                }
//                
//                return schedule.contains { weekDay in
//                    weekDay.rawValue == selectedWeekDay
//                }
//            }
//            
//            if filteredTrackers.isEmpty {
//                return nil
//            }
//            
//            return TrackerCategory(title: category.title, trackers: filteredTrackers)
//        }

    }
    
    
}

struct Tracker2: Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]?
    let trackerType: TrackerTypes
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeData(in: self)
    }
    
}
