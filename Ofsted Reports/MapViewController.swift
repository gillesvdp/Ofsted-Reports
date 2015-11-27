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
    
    /// MARK: Constants and Variables

    @IBOutlet weak var mapView: MKMapView!
    var viewTitle = String()
    var filterPrefs = [[String]]()
    var search : Search?
    var selectedSchool : School?
    
    /// MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        filterPrefs = NSUserDefaults.standardUserDefaults().valueForKey("filterPrefs") as! [[String]]
        mapView.removeAnnotations(mapView.annotations)
        loadPins()
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.title == "0 schools" {
            showAlertViewController("Warning", errorMessage: "There are schools in the location and search radius selected, but no schools match the current set of filters. Please adapt your filters to see schools in this area.")
        }
    }
    
    /// MARK: MapView functions
    func loadPins() {
        if let _ = search {
            let schools = CoreDataStackManager.sharedInstance.retrieveSchoolsOfSearch(search!)
            var schoolPins = [MKPointAnnotation]()
            for school in schools {
                if school.matchesUserPreferences() == true {
                    // If a school passes all the above if statements, it matches the filteria.
                    // A Pin for the school is creates.
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
            }
            self.title = "\(schoolPins.count) schools"
            if schoolPins.count == 1{
                self.title = "1 school"
            }
            mapView.showAnnotations(schoolPins, animated: true)
            mapView.addAnnotations(schoolPins)
        } else {
            // Error: no search was given to load the map
            showAlertViewController("Error", errorMessage: "Please try again with another search, or contact us if the problem persists")
        }
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
    
    /// MARK: General UI Functions
    
    func showAlertViewController(title: String, errorMessage: String) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: ConstantStrings.sharedInstance.errorOk, style: .Cancel, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ConstantStrings.sharedInstance.showSchoolDetails {
            let destinationVC = segue.destinationViewController as! SchoolDetailsViewController
            let selectedPin = sender as! MKPinAnnotationView
            destinationVC.school = CoreDataStackManager.sharedInstance.retrieveSchool(selectedPin.annotation!.coordinate.latitude, longitude: selectedPin.annotation!.coordinate.longitude)
        }
        if segue.identifier == ConstantStrings.sharedInstance.showSettings {
            let destinationVC = segue.destinationViewController as! SettingsTableViewController
            if let _ = search {
                destinationVC.search = self.search
            }
        }
    }
}
