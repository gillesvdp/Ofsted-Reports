//
//  ViewController.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    let accessApi = AccessAPI()
    
    @IBOutlet weak var labelOutlet: UILabel!
    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var buttonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ConstantStrings.sharedInstance.welcomeViewControllerTitle
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        guard textFieldOutlet.text != "" else {
            let alert = UIAlertController(title: ConstantStrings.sharedInstance.errorTitle, message: ConstantStrings.sharedInstance.noPostCodeErrorMessage, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: ConstantStrings.sharedInstance.errorOk, style: .Cancel, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // Saving the newSearch
        let newSearch = CoreDataStackManager.sharedInstance.saveNewSearch(self.textFieldOutlet.text!)
        
        // Searching for schools through the Api
        
        /// COMMENTED TO AVOID ACCESSING THE API WHILE SETTING UP OTHER APP FUNCTIONS
        /*
        accessApi.get(textFieldOutlet.text!,
            completionHandler: {(schoolsInfoArray, errorString) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    guard errorString == nil else {
                        let alert = UIAlertController(title: ConstantStrings.sharedInstance.errorTitle, message: errorString, preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: ConstantStrings.sharedInstance.errorOk, style: .Cancel, handler: nil)
                        alert.addAction(okAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                        return
                    }
                    
                    // Saving the schools retrieved from the Api
                    CoreDataStackManager.sharedInstance.saveNewSchools(newSearch, schoolsInfoArray: schoolsInfoArray!)
                    
                    // Moving to the mapView
                    self.performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: self)
                })
        })
        */
        self.performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! MapViewController
        destinationVC.viewTitle = textFieldOutlet.text!
        // destinationVC.search = newSearch
    }
}

