//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 28.03.2024.
//

import CoreData
import UIKit

private enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTrackers
    case trackerMappingFailed
    case getTrackerCategoriesFromCoreDataError
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didChangeData(in store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private override init() {}
    
    private var trackerStore = TrackerStore.shared
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        //let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@ AND %K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.trackerType),
            TrackerTypes.regularEvent.rawValue,
            #keyPath(TrackerCoreData.schedule),
            String(2)
        )
        
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCategoryCoreData.title),
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        
        return controller
    }()
    
    var categories = [TrackerCategory]()
    
//    var trackerCategories: [TrackerCategory] {
//        guard
//            let objects = self.fetchedResultsController.fetchedObjects,
//            let trackerCategories = try? objects.map({ try self.trackerCategory(from: $0)})
//        else { return [TrackerCategory]() }
//        return trackerCategories
//    }
    
    func getTrackerCategories() throws -> [TrackerCategory] {

        guard let objects = fetchedResultsController.fetchedObjects else {
            throw TrackerCategoryStoreError.getTrackerCategoriesFromCoreDataError
        }
        
        //TrackerStore.shared.filterCategoriesByWeekDay(selectedWeekDay: 2)
        guard let trackers = TrackerStore.shared.fetchedResultsController.fetchedObjects else {
            throw TrackerCategoryStoreError.getTrackerCategoriesFromCoreDataError
        }
        let categories = try objects.map {
            try trackerCategory(from: $0)
            //print("123")
        }
        
        
//        let trackers2 = try trackers.map {_ in
//            try TrackerStore.shared.tracker(from: TrackerStore.shared.allTrackers[0])
//        }
//        let trackers3 = try TrackerStore.shared.tracker(from: TrackerStore.shared.allTrackers[0])
//        print("TRACKERS MAPPED:-----------------:\(trackers3)")
//        
//        let categories2 = categories.map {
//            TrackerCategory(title: $0.title, trackers: trackers2)
//        }
        
        
        
        
        return categories
    }
    
    

    func trackerCategory(from trackerCategoriesCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoriesCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        
        guard let trackersCoreDataSet = trackerCategoriesCoreData.trackers as? Set<TrackerCoreData> else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTrackers
        }
        
        let trackers = try trackersCoreDataSet.compactMap { trackerCoreData in
            guard let tracker = try? trackerStore.tracker(from: trackerCoreData) else {
                throw TrackerCategoryStoreError.trackerMappingFailed
            }
            return tracker
        }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
//    func addTrackerCategory(_ category: TrackerCategory) throws {
//        let trackerCoreData = try trackerStore.addTracker(category.trackers[0], to: category)
//        let categoryCoreData = TrackerCategoryCoreData(context: context)
//        categoryCoreData.title = category.title
//        categoryCoreData.trackers = category.trackers
//        appDelegate.saveContext()
//    }
    
    func AddCategory(title: String) {
        //check unique
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        categoryCoreData.trackers = NSSet()
        appDelegate.saveContext()
    }
    
    func newCategory(title: String) throws -> TrackerCategoryCoreData? {
        var trackerCategoryCoreData: TrackerCategoryCoreData?
        
        if let categories = fetchedResultsController.fetchedObjects {
            categories.forEach { category in
                if category.title == title {
                    trackerCategoryCoreData = category
                }
            }
        }
        return trackerCategoryCoreData
        
        /*
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerCategoryCoreData.title), title
        )
        guard let categoryCoreData = try context.fetch(request).first else {
            throw TrackerCategoryStoreError.trackerMappingFailed
        }
        return categoryCoreData
        */
        
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeData(in: self)
    }
}
