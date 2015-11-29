//
//  SchoolDetailsCustomCell.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/29/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit

class SchoolDetailsCustomCell: UITableViewCell {

    @IBOutlet weak var titleLabelOutlet: UILabel!
    @IBOutlet weak var detailLabelOutlet: UILabel!

    var url : String?
    @IBOutlet weak var openUrlButtonOutlet: UIButton!
    @IBAction func openUrlButtonPressed(sender: AnyObject) {
        if let _ = url {
            UIApplication.sharedApplication().openURL(NSURL(string: url!)!)
        }
    }
}
