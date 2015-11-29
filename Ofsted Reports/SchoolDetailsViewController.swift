//
//  SchoolDetailsViewController.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/24/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit

class SchoolDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Variables & IB Outlets
    var school: School?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var schoolNameLabelOutlet: UILabel!
    
    let rowTitles : [String] = [
        "Phase",
        "Type of establishment",
        "Overall effectiveness",
        "Leadership and management",
        "Teaching quality",
        "Urn",
        "Last inspection date",
        "Report url"
    ]
    
    var rowDetails : [String: String] = [
        "Phase" : "",
        "Type of establishment" : "",
        "Overall effectiveness" : "",
        "Leadership and management" : "",
        "Teaching quality" : "",
        "Urn" : "",
        "Last inspection date" : "",
        "Report url" : ""
    ]
    
    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "map"), style: .Plain , target: self, action: "popToRootController")
    }
    
    override func viewWillAppear(animated: Bool) {
        // Preparing data for the table
        if let _ = school {
            schoolNameLabelOutlet.text = school!.schoolName
            
            if let phase = school!.phase {
                rowDetails["Phase"] = phase
            }
            
            if let typeOfEstablishment = school!.typeOfEstablishment {
                rowDetails["Type of establishment"] = typeOfEstablishment
            }
            
            if let _ = school!.overallEffectivenessSchoolRating.text {
                rowDetails["Overall effectiveness"] = school!.overallEffectivenessSchoolRating.text
            }
            
            if let _ = school!.leadershipAndManagementSchoolRating.text {
                rowDetails["Leadership and management"] = school!.leadershipAndManagementSchoolRating.text
            }
            
            if let _ = school!.qualityOfTeachingSchoolRating.text {
                rowDetails["Teaching quality"] = school!.qualityOfTeachingSchoolRating.text
            }
            
            if let urn = school!.urn {
                rowDetails["Urn"] = String(urn)
            }
            
            if let lastInspectionDate = school!.lastInspectionDate {
                rowDetails["Last inspection date"] = lastInspectionDate
            }
            
            if let url = school!.lastInspectionUrl {
                if url.containsString("ofsted.gov.uk") {
                    rowDetails["Report url"] = url
                }
            } else {
                rowDetails["Report url"] = "Report not available"
            }
        } else {
            // Error: No school was given to this class when it was created.
            showAlertViewController(ConstantStrings.sharedInstance.noSearchGivenToSchoolDetailTableViewControllerErrorTitle, errorMessage: ConstantStrings.sharedInstance.noSearchGivenToSchoolDetailTableViewControllerErrorMessage)
        }
        
        // Refreshing the table view just before the view appears
        tableView.reloadData()
    }
    
    /// MARK: TableView Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ConstantStrings.sharedInstance.tableReuseIdentifier, forIndexPath: indexPath) as! SchoolDetailsCustomCell
        
        // For all rows except the last one: show the 2 labels, and hide the button
        if indexPath.row < (rowTitles.count - 1) {
            cell.titleLabelOutlet.hidden = false
            cell.detailLabelOutlet.hidden = false
            cell.openUrlButtonOutlet.hidden = true
            cell.titleLabelOutlet.text = rowTitles[indexPath.row]
            cell.detailLabelOutlet.text = rowDetails[rowTitles[indexPath.row]]
            
        // For the last row, hide the 2 labels and use the button
        } else {
            cell.titleLabelOutlet.hidden = true
            cell.detailLabelOutlet.hidden = true
            cell.openUrlButtonOutlet.hidden = false
            
            if rowDetails["Report url"] == "Report not available" {
                // There was no valid url from the API.
                cell.openUrlButtonOutlet.enabled = false
                cell.openUrlButtonOutlet.setTitle("Report not available Ofsted Report", forState: .Normal)
                
            } else {
                // There was a value url from the API.
                cell.url = rowDetails["Report url"]
                cell.openUrlButtonOutlet.enabled = true
                cell.openUrlButtonOutlet.setTitle("Access Ofsted Report", forState: .Normal)
            }
        }
        return cell
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
