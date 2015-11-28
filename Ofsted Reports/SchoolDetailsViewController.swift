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
    
    @IBOutlet weak var schoolNameLabelOutlet: UILabel!
    @IBOutlet weak var phaseLabelOutlet: UILabel!
    @IBOutlet weak var typeOfEstablishmentLabelOutlet: UILabel!
    @IBOutlet weak var overallEffectivenessLabelOutlet: UILabel!
    @IBOutlet weak var leadershipAndManagementLabelOutlet: UILabel!
    @IBOutlet weak var teachingQualityLabelOutlet: UILabel!
    @IBOutlet weak var urnLabelOutlet: UILabel!
    @IBOutlet weak var lastInspectionDateLabelOutlet: UILabel!
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
            schoolNameLabelOutlet.text = school!.schoolName
            
            if let phase = school!.phase {
                phaseLabelOutlet.text = phase
            }
            
            if let typeOfEstablishment = school!.typeOfEstablishment {
                typeOfEstablishmentLabelOutlet.text = typeOfEstablishment
            }
            if let _ = school!.overallEffectivenessSchoolRating.text {
                overallEffectivenessLabelOutlet.text = school!.overallEffectivenessSchoolRating.text
            }
            
            if let _ = school!.leadershipAndManagementSchoolRating.text {
                leadershipAndManagementLabelOutlet.text = school!.leadershipAndManagementSchoolRating.text
            }
            
            if let _ = school!.qualityOfTeachingSchoolRating.text {
                teachingQualityLabelOutlet.text = school!.qualityOfTeachingSchoolRating.text
            }
            
            if let urn = school!.urn {
                urnLabelOutlet.text = String(urn)
            }
            
            if let lastInspectionDate = school!.lastInspectionDate {
                lastInspectionDateLabelOutlet.text = lastInspectionDate
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
            showAlertViewController(ConstantStrings.sharedInstance.noSearchGivenToSchoolDetailTableViewControllerErrorTitle, errorMessage: ConstantStrings.sharedInstance.noSearchGivenToSchoolDetailTableViewControllerErrorMessage)
        }
    }
    
    /// MARK: IB Actions
    @IBAction func btnPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: schoolReportUrl)!)
    }
    
    /// MARK: General Functions
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
