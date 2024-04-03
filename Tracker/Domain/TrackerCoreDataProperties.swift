//
//  TrackerCoreDataProperties.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 29.03.2024.
//

import CoreData
import UIKit

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject {
    
}

extension TrackerCoreData {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
    
    @NSManaged public var color: UIColor?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var schedule: String?
    @NSManaged public var title: String?
    @NSManaged public var trackerType: String?
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var records: NSSet?
    
}

// MARK: Generated accessors for records
extension TrackerCoreData {
    
    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: TrackerRecordCoreData)
    
    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: TrackerRecordCoreData)
    
    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)
    
    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)
    
}

extension TrackerCoreData : Identifiable {
    
}
