//
//  CoreDataStackManager.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import CoreData
import UIKit

private let SQLITE_FILE_NAME = "Ofsted_Reports.sqlite"

class CoreDataStackManager {
    
    static var sharedInstance = CoreDataStackManager()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.gillesvdp.Ofsted_Reports" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Ofsted_Reports", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Ofsted_Reports.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Error: Failed to save the context")
            }
        }
    }
    
    // MARK: Data Management
    
    /// Functions for WelcomeViewController
    func fetchPreviousSearches() -> [Search] {
        var funcReturn = [Search]()
        
        let request = NSFetchRequest(entityName: "Search")
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let allPreviousSearches = try managedObjectContext.executeFetchRequest(request) as! [Search]
            funcReturn = allPreviousSearches
        } catch {
            print("Error: Failed to execute the fetch request (fetchPreviousSearches)")
        }
        return funcReturn
    }
    
    func saveNewSearch(postCode: String?, latitude: Double, longitude: Double, radius: Int, description: String) -> Search {
        let newSearch = Search(postCode: postCode, latitude: latitude, longitude: longitude, radius: radius, description: description, context: managedObjectContext)
        saveContext()
        return newSearch
    }
    
    func updateSearchDescription(search: Search, description: String) {
        search.textDescription = description
        saveContext()
    }
    
    func saveNewSchools(search: Search, schoolsInfoArray: [[String: AnyObject]]) {
        for school in schoolsInfoArray {
            let distanceMetres = school["distanceMetres"] as? Int
            let lastInspectionDate = school["lastInspectionDate"] as? String
            let lastInspectionUrl = school["lastInspectionUrl"] as? String
            let leadershipAndManagement = school["leadershipAndManagement"] as? Int
            let latitude = school["location"]!["lat"] as? Double
            let longitude = school["location"]!["lon"] as? Double
            let overallEffectiveness = school["overallEffectiveness"] as? Int
            let phase = school["phase"] as? String
            let qualityOfTeaching = school["qualityOfTeaching"] as? Int
            let schoolName = school["schoolName"] as? String
            let typeOfEstablishment = school["typeOfEstablishment"] as? String
            let urn = school["urn"] as? Int
            
            // Creating new School
            _ = School(distanceMetres: distanceMetres, lastInspectionDate: lastInspectionDate, lastInspectionUrl: lastInspectionUrl, latitude: latitude, leadershipAndManagement: leadershipAndManagement, longitude: longitude, overallEffectiveness: overallEffectiveness, phase: phase, qualityOfTeaching: qualityOfTeaching, schoolName: schoolName, typeOfEstablishment: typeOfEstablishment, urn: urn, search: search, context: managedObjectContext)
        }
        saveContext()
    }
    
    func deleteSearchAndItsSchools(search: Search) {
        if let _ = search.schools {
            for school in search.schools! {
                managedObjectContext.deleteObject(school as NSManagedObject)
            }
        }
        managedObjectContext.deleteObject(search)
        saveContext()
    }
}