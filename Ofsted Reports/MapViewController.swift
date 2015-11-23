//
//  mapViewController.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var viewTitle = String()
    var search = Search()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Schools near \(viewTitle)"
    }
}
