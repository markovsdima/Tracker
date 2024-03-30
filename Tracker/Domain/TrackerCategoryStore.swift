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
}

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    private override init() {}
    
    private var trackerStore = TrackerStore.shared
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
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
    
    var trackerCategories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackerCategories = try? objects.map({ try self.trackerCategory(from: $0)})
        else { return [TrackerCategory]() }
        return trackerCategories
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
    
    func addTrackerCategorie(title: String) throws {
        
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
}
