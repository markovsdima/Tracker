//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 28.03.2024.
//

import CoreData
import UIKit

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTrackers
    case trackerMappingFailed
    case getTrackerCategoriesFromCoreDataError
    case categoryExist
    case fetchCategoriesFailed
    case otherError
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didChangeData(in store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private override init() {}
    
    // MARK: - Private Properties
    private var trackerStore = TrackerStore.shared
    
    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }
    
    private var context: NSManagedObjectContext? {
        appDelegate?.persistentContainer.viewContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>? = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
        guard let context else { return nil }
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
    
    private var categories = [TrackerCategory]()
    
    // MARK: - Public Methods
    public func fetchCategories() throws -> [TrackerCategory] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            throw TrackerCategoryStoreError.fetchCategoriesFailed
        }
        let categories = try objects.map { try trackerCategory(from: $0) }
        
        return categories
    }
    
    public func addCategory(title: String) throws {
        guard let context else { throw TrackerCategoryStoreError.otherError }
        //check unique
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        
        let findCategory = try? context.fetch(fetchRequest)
        let trackerCategory: TrackerCategoryCoreData
        
        if (findCategory?.first) != nil {
            throw TrackerCategoryStoreError.categoryExist
        } else {
            trackerCategory = TrackerCategoryCoreData(context: context)
            trackerCategory.title = title
            trackerCategory.trackers = NSSet()
        }
        
        appDelegate?.saveContext()
    }
    
    // MARK: - Private Methods
    private func trackerCategory(from trackerCategoriesCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoriesCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        
        return TrackerCategory(title: title, trackers: [])
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeData(in: self)
    }
}
