//
//  SettingsTableViewController.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/24/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    /// MARK: IBOutlets, Variables & related function
    
    var search: Search?
    
    @IBOutlet weak var toolbarButton: UIBarButtonItem!
    
    var filterPrefs : [[String]]!
    func saveFilterPrefs(filterPrefs: [[String]]) {
        NSUserDefaults.standardUserDefaults().setValue(filterPrefs, forKey: "filterPrefs")
    }
    
    /// MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "map"), style: .Plain , target: self, action: "popToRootController")
    }
    
    override func viewWillAppear(animated: Bool) {
        toolbarButton.enabled = false // The buttun is only used to display next, and never acts as a button: thus disabled.
        filterPrefs = NSUserDefaults.standardUserDefaults().valueForKey("filterPrefs") as! [[String]]
        refreshNumberOfSchoolsThatMatchCriteria()
    }
    
    /// MARK: Table data & functions
    let sectionTitles = ["School Phase","Latest Ofsted Rating"]
    let rowTitles = [["Secondary", "Primary", "Others"],["Outstanding", "Good", "Requires improvement", "Inadequate"]]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.text = rowTitles[indexPath.section][indexPath.row]
        cell.detailTextLabel?.text = filterPrefs[indexPath.section][indexPath.row]
        if cell.detailTextLabel?.text == "Yes" {
            cell.detailTextLabel?.textColor = UIColor.greenColor()
        } else {
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell!.detailTextLabel!.text == "Yes" {
            cell!.detailTextLabel!.text = "No"
            filterPrefs[indexPath.section][indexPath.row] = "No"
            saveFilterPrefs(filterPrefs)
            cell!.detailTextLabel!.textColor = UIColor.lightGrayColor()
        } else {
            cell!.detailTextLabel!.text = "Yes"
            filterPrefs[indexPath.section][indexPath.row] = "Yes"
            saveFilterPrefs(filterPrefs)
            cell!.detailTextLabel!.textColor = UIColor.greenColor()
        }
        refreshNumberOfSchoolsThatMatchCriteria()
    }
    
    /// MARK: General UI Functions
    func refreshNumberOfSchoolsThatMatchCriteria() {
        if let _ = search {
            let schools = CoreDataStackManager.sharedInstance.retrieveSchoolsOfSearch(search!)
            var counterOfSchoolsThatMatchUserPreferences = 0
            for school in schools {
                if school.matchesUserPreferences() == true {
                    counterOfSchoolsThatMatchUserPreferences += 1
                }
            }
            toolbarButton.title = "\(counterOfSchoolsThatMatchUserPreferences) schools match your criteria"
        } else {
            // Error: No Search was passed to this viewController
        }
    }
    
    func popToRootController() {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
}
