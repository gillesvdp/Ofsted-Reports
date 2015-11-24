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
        mapView.delegate = self
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
            schoolPin.title = school.schoolName
            if let typeOfEstablishment = school.typeOfEstablishment {
                if let phase = school.phase {
                    schoolPin.subtitle = "\(phase), \(typeOfEstablishment)"
                }
            }
            
            schoolPins.append(schoolPin)
        }
        mapView.showAnnotations(schoolPins, animated: true)
        mapView.addAnnotations(schoolPins)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(ConstantStrings.sharedInstance.mapAnnotationReuseIdentifier) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ConstantStrings.sharedInstance.mapAnnotationReuseIdentifier)
            pin!.canShowCallout = true
            pin!.pinTintColor = UIColor.redColor()
            pin!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pin!.annotation = annotation
        }
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier(ConstantStrings.sharedInstance.showSchoolDetails, sender: view)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ConstantStrings.sharedInstance.showSchoolDetails {
            let destinationVC = segue.destinationViewController as! SchoolDetailsTableViewController
            let selectedPin = sender as! MKPinAnnotationView
            destinationVC.schoolUrn = CoreDataStackManager.sharedInstance.retrieveSchoolUrn(selectedPin.annotation!.coordinate.latitude, longitude: selectedPin.annotation!.coordinate.longitude)
        }
    }
}
