//
//  mapViewController.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var viewTitle = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Schools near \(viewTitle)"
        loadPins()
    }
    
    func loadPins() {
        let schools = CoreDataStackManager.sharedInstance.retrieveSchoolsOfSearch()
        
        var schoolPins = [MKPointAnnotation]()
        for school in schools {
            let pinLatitude = school.latitude as! Double
            let pinLongitude = school.longitude as! Double
            
            let coordinate = CLLocationCoordinate2D(latitude: pinLatitude, longitude: pinLongitude)
            let schoolPin = MKPointAnnotation()
            schoolPin.coordinate = coordinate
            schoolPins.append(schoolPin)
        }
        mapView.showAnnotations(schoolPins, animated: true)
        mapView.addAnnotations(schoolPins)
        
    }
}
