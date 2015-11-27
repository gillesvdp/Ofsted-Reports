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

