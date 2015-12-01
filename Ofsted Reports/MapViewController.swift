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
    var schools : [School]?
    
    /// MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        filterPrefs = NSUserDefaults.standardUserDefaults().valueForKey("filterPrefs") as! [[String]]
        mapView.removeAnnotations(mapView.annotations)
        prepareMapAnnotations()
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.title == "0 schools" {
            // Showing a warning: no schools appear on the map because no schools in this search match the user preferences
            // Title is set in loadPins method, and if is equal to 0 schools, there are no schools to show on the map.
            showAlertViewController(ConstantStrings.sharedInstance.noSchoolsMatchCurrentPrefsWarningTitle, errorMessage: ConstantStrings.sharedInstance.noSchoolsMatchCurrentPrefsWarningMessage)
        }
    }
    
    /// MARK: MapView functions
    func prepareMapAnnotations() {
        if let _ = search {
            if let schools = search!.schools {
                var schoolPins = [MKPointAnnotation]()
                for school in schools {
                    if school.matchesUserPreferences() == true {
                        // If a school passes all the above if statements, it matches the filteria.
                        // A Pin for the school is creates.
                        let pinLatitude = school.latitude as! Double
                        let pinLongitude = school.longitude as! Double
                        let coordinate = CLLocationCoordinate2D(latitude: pinLatitude, longitude: pinLongitude)
                        
                        let schoolPin = MapCustomPointAnnotation()
                        schoolPin.school = school
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
                // Setting title of MapViewController based on number of pins
                if schoolPins.count == 1 {
                    self.title = "1 school"
                } else {
                    self.title = "\(schoolPins.count) schools"
                }
                
                mapView.addAnnotations(schoolPins)
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                })
            } else {
                // Error: search.schools has a nil value 
                showAlertViewController(ConstantStrings.sharedInstance.noSearchGivenToSettingTableViewControllerErrorTitle, errorMessage: ConstantStrings.sharedInstance.noSchoolsAttachedToTheSearhErrorMessage)
            }
        } else {
            // Error: no search was given to load the map
            showAlertViewController(ConstantStrings.sharedInstance.noSearchGivenToMapViewControllerErrorTitle, errorMessage: ConstantStrings.sharedInstance.noSearchGivenToMapViewControllerErrorMessage)
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
        // If going to the SchoolDetailsViewController
        if segue.identifier == ConstantStrings.sharedInstance.showSchoolDetails {
            let destinationVC = segue.destinationViewController as! SchoolDetailsViewController
            let selectedPin = sender as! MKPinAnnotationView
            let annotation = selectedPin.annotation as! MapCustomPointAnnotation
            destinationVC.school = annotation.school
        }
        
        // If going to the SettingsTableViewController
        if segue.identifier == ConstantStrings.sharedInstance.showSettings {
            let destinationVC = segue.destinationViewController as! SettingsTableViewController
            if let _ = search {
                destinationVC.search = self.search
            }
        }
    }
}
