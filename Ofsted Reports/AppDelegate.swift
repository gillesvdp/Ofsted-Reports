//
//  AppDelegate.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Generate Singletons
        _ = ConstantStrings()
        _ = CoreDataStackManager()
        
        // Setting standard school filters if the app is launched for the first time (useful on MapViewController, SettingsViewController, and School objects).
        if NSUserDefaults.standardUserDefaults().valueForKey("filterPrefs") == nil {
            let filterPrefsInit = [["Yes","Yes","Yes"],["Yes","Yes","Yes","Yes"]]
            NSUserDefaults.standardUserDefaults().setValue(filterPrefsInit, forKey: "filterPrefs")
        }
        
        // Forgetting the welcomeScreenOutletValues.
        // The welcome screen will be set-up with standard values.
        // The welcome screen outlet values are kept in NSUserDefaults only within the same application run time.
        let defaults = NSUserDefaults.standardUserDefaults()
        if let _ = defaults.valueForKey("welcomeScreenOutletValues") {
            defaults.removeObjectForKey("welcomeScreenOutletValues")
        }
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
        // Saving the context
        CoreDataStackManager.sharedInstance.saveContext()
        
    }
}

