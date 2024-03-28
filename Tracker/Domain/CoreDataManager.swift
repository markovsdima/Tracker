//
//  CoreDataManager.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 28.03.2024.
//

import CoreData
import UIKit

// MARK: CRUD
public final class CoreDataManager: NSObject {
    public static let shared = CoreDataManager()
    private override init() { }
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func getTracker() -> TrackerCoreData {
        let tracker = TrackerCoreData(context: context)
        return tracker
    }
    
}
