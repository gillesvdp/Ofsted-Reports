//
//  WelcomeVCExtensionTableViewFuncs.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/30/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import UIKit

extension WelcomeViewController {
    
    //// MARK: TableView Functions
    // The table view displays the list of previous searches
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousSearches!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = previousSearches![indexPath.row].textForTableCell!
        cell.detailTextLabel!.text = "\(previousSearches![indexPath.row].radius!) m"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchToSendToMapViewController = previousSearches![indexPath.row]
        performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Deleting the search from the CoreDataStackManager
            CoreDataStackManager.sharedInstance.deleteSearchAndItsSchools(previousSearches![indexPath.row])
            
            // Refresh content of previousSearches variable in this class (required, as this is used to populate the table)
            previousSearches = CoreDataStackManager.sharedInstance.fetchPreviousSearches()
            
            // Deleting the row from the table
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
}