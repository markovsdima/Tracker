//
//  AppDelegate.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 10.02.2024.
//

import CoreData
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.rootViewController = chooseInitialViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - Choose Initial ViewController
    func chooseInitialViewController() -> UIViewController {
        let firstLaunchTookPlace = UserDefaults.standard.bool(forKey: "firstLaunchTookPlace")
        
        // Set filtration type to default(allTrackers)
        UserDefaults.standard.set(0, forKey: "filterType")
        
        let controller = firstLaunchTookPlace ? TabBarViewController() : OnboardingViewController()
        
        return controller
    }
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unable to Save Context, \(nserror)")
            }
        }
    }
    
}
