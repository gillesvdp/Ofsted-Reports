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
        
        // Setting standard filters if the app is launched for the first time (useful on MapViewController, SettingsViewController, and School objects).
        if NSUserDefaults.standardUserDefaults().valueForKey("filterPrefs") == nil {
            let filterPrefsInit = [["Yes","Yes","Yes"],["Yes","Yes","Yes","Yes"]]
            NSUserDefaults.standardUserDefaults().setValue(filterPrefsInit, forKey: "filterPrefs")
        }
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        
        // Saving the context
        CoreDataStackManager.sharedInstance.saveContext()
        
        // Forgetting the welcomeScreenOutletValues. 
        // The next time the app launches, it will have a fresh welcomeScreen.
        let defaults = NSUserDefaults.standardUserDefaults()
        if let _ = defaults.valueForKey("welcomeScreenOutletValues") {
            defaults.removeObjectForKey("welcomeScreenOutletValues")
        }
    }
}

