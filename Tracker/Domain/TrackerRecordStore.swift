//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 28.03.2024.
//

import CoreData
import UIKit

private enum TrackerRecordStoreError: Error {
    case contextCastingError
    case otherError
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func didChangeData(in store: TrackerRecordStore)
    // TODO: Разобраться
    /// Никуда не ведет, но без него почему-то не обновляется коллекция при смене даты
}

final class TrackerRecordStore: NSObject {
    
    static let shared = TrackerRecordStore()
    private override init() {}
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Private Properties
    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }
    
    private var context: NSManagedObjectContext? {
        appDelegate?.persistentContainer.viewContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>? = {
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
        ]
        guard let context else { return nil }
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
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
    
    
    // MARK: - Public Methods
    public func fetchTrackerRecord() throws -> Set<TrackerRecord> {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        let trackersRecords: Set<TrackerRecord> = Set(objects.map {
            TrackerRecord(
                id: $0.trackerId ?? UUID(),
                date: $0.date ?? Date()
            )
        })

        return trackersRecords
    }
    
    public func addTrackerRecord(for tracker: Tracker, date: Date) {
        
        guard let context else { return }
        
        if tracker.trackerType == .oneTimeEvent {
            let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "trackerId == %@ AND date == %@", tracker.id as CVarArg, Date() as CVarArg)
            
            do {
                let existingRecords = try context.fetch(fetchRequest)
                if existingRecords.count > 0 {
                    // У трекера уже есть запись
                    return
                }
                
                // Создание и сохранение записи
                let trackerRecordCoreData = TrackerRecordCoreData(context: context)
                
                trackerRecordCoreData.date = date
                trackerRecordCoreData.trackerId = tracker.id
                
                try context.save()
            } catch let error as NSError {
                print("Could not save record: \(error)")
            }
        } else {
            do {
                // Создание и сохранение записи
                let trackerRecordCoreData = TrackerRecordCoreData(context: context)
                
                trackerRecordCoreData.date = date
                trackerRecordCoreData.trackerId = tracker.id
                
                try context.save()
            } catch let error as NSError {
                print("Could not save record: \(error)")
            }
        }
        
    }
    
    public func removeRecord(id: UUID, date: Date) throws {
        guard let context else { return }
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.trackerId),
            id as CVarArg,
            #keyPath(TrackerRecordCoreData.date),
            date as NSDate
        )
        
        let record = try context.fetch(request)
        if let record = record.first {
            context.delete(record)
        }
        
        try context.save()
    }
    
}
// MARK: NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeData(in: self)
    }
}
