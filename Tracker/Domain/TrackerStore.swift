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

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
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
    
    
//    func addTracker(_ tracker: Tracker) throws {
//        let trackerCoreData = TrackerCoreData(context: context)
//        
//        trackerCoreData.id = tracker.id
//        trackerCoreData.title = tracker.title
//        trackerCoreData.color = tracker.color
//        trackerCoreData.emoji = tracker.emoji
//        trackerCoreData.schedule = WeekDay.convertScheduleToString(tracker.schedule ?? nil)
//        
//        try context.save()
//    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let color = trackerCoreData.color,
            let emoji = trackerCoreData.emoji,
            let schedule = trackerCoreData.schedule
            //let trackerType = trackerCoreData.trackerType
        else { throw  TrackerStoreError.decodingTrackerError }
        
        let trackerType = trackerCoreData.trackerType
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: WeekDay.getScheduleFromString(daysString: schedule),
            trackerType: TrackerTypes.getTrackerTypeFromInt(integer16: trackerType))
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
