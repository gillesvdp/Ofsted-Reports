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
    var filterPrefs = [[String]]()
    var search : Search?
    var selectedSchool : School?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Setting standard filters if the map is launched for the first time
        if NSUserDefaults.standardUserDefaults().valueForKey("filterPrefs") == nil {
            let filterPrefsInit = [["Yes","Yes","Yes"],["Yes","Yes","Yes","Yes"]]
            NSUserDefaults.standardUserDefaults().setValue(filterPrefsInit, forKey: "filterPrefs")
            filterPrefs = filterPrefsInit
        } else {
            filterPrefs = NSUserDefaults.standardUserDefaults().valueForKey("filterPrefs") as! [[String]]
        }
        mapView.removeAnnotations(mapView.annotations)
        loadPins()
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.title == "0 schools" {
            showAlertViewController("Warning", errorMessage: "There are schools in the location and search radius selected, but no schools match the current set of filters. Please adapt your filters to see schools in this area.")
        }
    }
    
    func loadPins() {
        if let _ = search {
            let schools = CoreDataStackManager.sharedInstance.retrieveSchoolsOfSearch(search!)
            var schoolPins = [MKPointAnnotation]()
            for school in schools {
                
                // Filtering school as per the filter preferences
                if filterPrefs[0][0] == "No" {
                    if school.phase == "Secondary" {
                        continue
                    }
                }
                
                if filterPrefs[0][1] == "No" {
                    if school.phase == "Primary" {
                        continue
                    }
                }
                if filterPrefs[0][2] == "No" {
                    if school.phase != "Secondary" && school.phase != "Primary" {
                        continue
                    }
                }
                if filterPrefs[1][0] == "No" {
                    if school.overallEffectiveness == 1 {
                        continue
                    }
                }
                if filterPrefs[1][1] == "No" {
                    if school.overallEffectiveness == 2 {
                        continue
                    }
                }
                if filterPrefs[1][2] == "No" {
                    if school.overallEffectiveness == 3 {
                        continue
                    }
                }
                if filterPrefs[1][3] == "No" {
                    if school.overallEffectiveness == 4 {
                        continue
                    }
                }
                
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
            self.title = "\(schoolPins.count) schools"
            if schoolPins.count == 1{
                self.title = "1 school"
            }
            mapView.showAnnotations(schoolPins, animated: true)
            mapView.addAnnotations(schoolPins)
        } else {
            print("no search was given to load the map")
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ConstantStrings.sharedInstance.showSchoolDetails {
            let destinationVC = segue.destinationViewController as! SchoolDetailsViewController
            let selectedPin = sender as! MKPinAnnotationView
            destinationVC.school = CoreDataStackManager.sharedInstance.retrieveSchool(selectedPin.annotation!.coordinate.latitude, longitude: selectedPin.annotation!.coordinate.longitude)
        }
    }
    
    func showAlertViewController(title: String, errorMessage: String) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: ConstantStrings.sharedInstance.errorOk, style: .Cancel, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
