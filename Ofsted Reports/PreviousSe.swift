//
//  SchoolDetailsTableViewController.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit

class SchoolDetailsTableViewController: UITableViewController {
    
    var schoolUrn = Int()
    var school : School!

    override func viewDidLoad() {
        super.viewDidLoad()
        school = CoreDataStackManager.sharedInstance.retrieveSchoolWithUrn(schoolUrn)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = "\(dataForRow(indexPath.row)[0]): \(dataForRow(indexPath.row)[1])"
        return cell
    }
    
    func dataForRow(row: Int) -> [String] {
        var funcReturn = [String]()
        
        switch row {
            case 0:     funcReturn = ["School name", school.schoolName!]
            case 1:     funcReturn = ["Type of Establishment", school.typeOfEstablishment!]
            case 2:     funcReturn = ["Teaching Quality", String(school.qualityOfTeaching!)]
            case 3:     funcReturn = ["Last Inspection Date", school.lastInspectionDate!]
            case 4:     funcReturn = ["Last Inspection Url", school.lastInspectionUrl!]
            case 5:     funcReturn = ["Leadership And Management", String(school.leadershipAndManagement!)]
            case 6:     funcReturn = ["Overall Effectiveness", String(school.overallEffectiveness!)]
            case 7:     funcReturn = ["Phase", school.phase!]
            case 8:     funcReturn = ["Type of Establishment", school.typeOfEstablishment!]
            case 9:     funcReturn = ["URN", String(school.urn!)]
            case 10:    funcReturn = ["PhotoLocalUrl", school.photoLocalUrl!]
            default:    break
        }
        
        return funcReturn
    }
    
}
