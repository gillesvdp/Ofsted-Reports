//
//  SettingsTableViewController.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/24/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var filterPrefs : [[String]]!
    
    func saveFilterPrefs(filterPrefs: [[String]]) {
        NSUserDefaults.standardUserDefaults().setValue(filterPrefs, forKey: "filterPrefs")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        filterPrefs = NSUserDefaults.standardUserDefaults().valueForKey("filterPrefs") as! [[String]]
    }
    
    /// Table data
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
    }
}
