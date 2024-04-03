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
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeData(in: self)
    }
}
