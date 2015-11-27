//
//  SchoolDetailsViewController.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/24/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit

class SchoolDetailsViewController: UIViewController {

    // MARK: Variables & IB Outlets
    
    var schoolUrn = Int()
    var school: School?
    var schoolReportUrl = String()
    
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var btnOutlet: UIButton!
    
    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "map"), style: .Plain , target: self, action: "popToRootController")
    }
    
    override func viewWillAppear(animated: Bool) {
        // Basic screen set up
        btnOutlet.enabled = true
        btnOutlet.setTitle("Access Ofsted Report", forState: .Normal)
        
        // Customizing screen based on the school info to be displayed
        if let _ = school {
            schoolName.text = school!.schoolName
            
            if let phase = school!.phase {
                label1.text = phase
            }
            
            if let typeOfEstablishment = school!.typeOfEstablishment {
                label2.text = typeOfEstablishment
            }
            
            if let overallEffectiveness = school!.overallEffectiveness {
                label3.text = ratingAsText(overallEffectiveness as Int)
            }
            
            if let leadershipAndManagement = school!.leadershipAndManagement {
                label4.text = ratingAsText(leadershipAndManagement as Int)
            }
            
            if let qualityOfTeaching = school!.qualityOfTeaching {
                label5.text = ratingAsText(qualityOfTeaching as Int)
            }
            
            if let urn = school!.urn {
                label6.text = String(urn)
            }
            
            if let lastInspectionDate = school!.lastInspectionDate {
                label7.text = lastInspectionDate
            }
            
            if let url = school!.lastInspectionUrl {
                if url.containsString("ofsted.gov.uk") {
                    self.schoolReportUrl = url
                }
            } else {
                btnOutlet.enabled = false
                btnOutlet.setTitle("Report not available", forState: .Normal)
            }
        } else {
            // Error: No school was given to this class when it was created.
            showAlertViewController("Error", errorMessage: "Please try with another school, or contact us if the problem persists")
        }
    }
    
    /// MARK: IB Actions
    
    @IBAction func btnPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: schoolReportUrl)!)
    }
    
    /// MARK: General Functions
    
    func ratingAsText(rating: Int) -> String {
        var funcReturn = String()
        switch rating {
            case 1: funcReturn = "Outstanding"
            case 2: funcReturn = "Good"
            case 3: funcReturn = "Requires improvement"
            case 4: funcReturn = "Inadequate"
            default: funcReturn = "Error: Please contact us"
        }
        return funcReturn
    }
    
    func showAlertViewController(title: String, errorMessage: String) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: ConstantStrings.sharedInstance.errorOk, style: .Cancel, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func popToRootController() {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
}
