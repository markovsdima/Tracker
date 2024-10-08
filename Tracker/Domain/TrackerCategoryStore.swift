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
    case getContextError
    case categoryDeleteError
    case categoryEditError
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
    func fetchCategories() throws -> [TrackerCategory] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            throw TrackerCategoryStoreError.fetchCategoriesFailed
        }
        let categories = try objects.map { try trackerCategory(from: $0) }
        
        return categories
    }
    
    func addCategory(title: String) throws {
        guard let context else { throw TrackerCategoryStoreError.getContextError }
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
    
    func editCategory(title: String, for existingTitle: String) throws {
        guard let context = context else { throw TrackerCategoryStoreError.getContextError }
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), existingTitle)
        
        let findCategory = try? context.fetch(fetchRequest)
        guard let categoryToEdit = findCategory?.first else {
            throw TrackerCategoryStoreError.categoryEditError
        }
        
        categoryToEdit.title = title
        
        appDelegate?.saveContext()
    }
    
    
    func deleteCategory(title: String) throws {
        guard let context else { throw TrackerCategoryStoreError.getContextError }
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        
        let findCategory = try? context.fetch(fetchRequest)
        
        guard let findCategory else { throw TrackerCategoryStoreError.categoryDeleteError }
        
        if (findCategory.first) != nil {
            guard let category = findCategory.first else { throw TrackerCategoryStoreError.categoryDeleteError }
            if category.trackers?.count ?? 0 > 0 {
                throw TrackerCategoryStoreError.otherError
            }
            context.delete(category)
        } else {
            throw TrackerCategoryStoreError.categoryDeleteError
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
