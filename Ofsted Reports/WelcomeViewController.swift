//
//  ViewController.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class WelcomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    /// MARK: Variables and constants
    let accessApi = AccessAPI()
    let locationManager = CLLocationManager()
    var searchRadius : Int {
        get {
            return Int(sliderOutlet.value) - Int(sliderOutlet.value) % 100
        }
    }
    var forceCenterOnUserLocation : Bool?
    var search : Search?
    
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sliderOutlet: UISlider!
    @IBOutlet weak var sliderValueLabelOutlet: UILabel!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var longPressOutlet: UILongPressGestureRecognizer!
    @IBOutlet weak var longPressInstruction: UILabel!
    
    /// MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ConstantStrings.sharedInstance.welcomeViewControllerTitle
        tableView.delegate = self
        locationManager.delegate = self
        textFieldOutlet.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    override func viewWillAppear(animated: Bool) {
        mapView.hidden = true
        mapView.showsUserLocation = false
        segmentedControlOutlet.enabled = true
        segmentedControlOutlet.selectedSegmentIndex = 1
        forceCenterOnUserLocation = true
        longPressOutlet.enabled = false
        longPressInstruction.hidden = true
    }
    
    /// MARK: IB Actions
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        switch segmentedControlOutlet.selectedSegmentIndex {
        case 0: // Search based on my location
            
            // Remove view elements needed for case 1
            textFieldOutlet.hidden = true
            textFieldOutlet.endEditing(true)
            
            // Remove view elements needed for case 2
            longPressOutlet.enabled = false
            longPressInstruction.hidden = true
            
            // Prepare view elements for case 0
            mapView.hidden = false
            mapView.removeAnnotations(mapView.annotations)
            locationManager.requestWhenInUseAuthorization()
            displayCurrentUserLocation()
            
        case 1: // Search by Post Code
            // Remove view elements needed for case 0
            mapView.hidden = true
            
            // Remove view elements needed for case 2
            mapView.hidden = true
            mapView.removeAnnotations(mapView.annotations)
            longPressOutlet.enabled = false
            longPressInstruction.hidden = true
            
            // Prepare view elements for case 1
            textFieldOutlet.hidden = false
            
        case 2: // Search by selecting a location
            // Remove view elements needed for case 0
            mapView.showsUserLocation = false
            
            // Remove view elements needed for case 1
            textFieldOutlet.hidden = true
            textFieldOutlet.endEditing(true)
            
            // Prepare view elements for case 3
            mapView.hidden = false
            forceCenterOnUserLocation = true
            longPressInstruction.hidden = false
            longPressOutlet.enabled = true
            
        default:
            break; 
        }
    }
    
    @IBAction func longPressAction(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began {
            longPressOutlet.enabled = false
            longPressOutlet.conformsToProtocol(MKMapViewDelegate)
            let touchPoint = longPressOutlet.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = newCoordinates
            mapView.addAnnotation(pinAnnotation)
        }
    }
    
    @IBAction func sliderMoved(sender: AnyObject) {
        sliderValueLabelOutlet.text = String(searchRadius) + " m"
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        defreezeScreen(false)
        activityIndicator.startAnimating()
        let radius = searchRadius
        
        // Search by Current Location
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            guard locationManager.location != nil else {
                defreezeScreen(true)
                showAlertViewController(ConstantStrings.sharedInstance.noUserLocationErrorTitle, errorMessage: ConstantStrings.sharedInstance.noUserLocationErrorMessage)
                return
            }
            
            // Search schools for this search
            let latitude = locationManager.location!.coordinate.latitude
            let longitude = locationManager.location!.coordinate.longitude
            
            searchSchools(nil, latitude: latitude, longitude: longitude, radius: radius)
        }
        
        // Search by Post Code
        if segmentedControlOutlet.selectedSegmentIndex == 1 {
            guard textFieldOutlet.text != "" else {
                defreezeScreen(true)
                showAlertViewController(ConstantStrings.sharedInstance.noPostCodeErrorTitle, errorMessage: ConstantStrings.sharedInstance.noPostCodeErrorMessage)
                return
            }
            
            // Search schools for this search
            searchSchools(textFieldOutlet.text!, latitude: nil, longitude: nil, radius: radius)
        }
        
        // Search by other location
        if segmentedControlOutlet.selectedSegmentIndex == 2 {
            guard mapView.annotations.count != 0 else {
                self.defreezeScreen(true)
                showAlertViewController(ConstantStrings.sharedInstance.noSelectedLocationErrorTitle, errorMessage: ConstantStrings.sharedInstance.noSelectedLocationErrorMessage)
                return
            }
            
            // Search schools for this search
            let latitude = mapView.annotations.first?.coordinate.latitude
            let longitude = mapView.annotations.first?.coordinate.longitude
            searchSchools(nil, latitude: latitude!, longitude: longitude!, radius: radius)
        }
    }
    
    /// MARK: General functions
    
    func searchSchools(postCode: String?, latitude: Double?, longitude: Double?, radius: Int) {
        accessApi.get(postCode, latitude: latitude, longitude: longitude, radius: radius,
            completionHandler: {(schoolsInfoArray, errorString) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    // If there is an error returned from the accessApi class
                    guard errorString == nil else {
                        self.defreezeScreen(true)
                        self.showAlertViewController(ConstantStrings.sharedInstance.errorTitle, errorMessage: errorString!)
                        return
                    }
                    
                    // If the api does not return an error, but returns 0 schools in the area
                    guard schoolsInfoArray!.count != 0 else {
                        self.defreezeScreen(true)
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        self.showAlertViewController(ConstantStrings.sharedInstance.noSchoolsInAreaErrorTitle, errorMessage: ConstantStrings.sharedInstance.noSchoolsInAreaErrorMessage)
                        return
                    }
                    
                    // Now we have results with at least 1 school info in the array; let's save the search and the related schools
                    self.saveSearchAndSchools(postCode, latitude: latitude, longitude: longitude, radius: radius, schoolsInfoArray: schoolsInfoArray!)
                })
        })
    }
    
    func saveSearchAndSchools(postCode: String?, latitude: Double?, longitude: Double?, radius: Int, schoolsInfoArray: [[String: AnyObject]]) {
        // Preparing to save the search (generating a basic string description for the search)
        var textForTableCell = String()
        if let _ = postCode {
            textForTableCell = postCode!
        } else {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            formatter.maximumFractionDigits = 2
            let latShortString = formatter.stringFromNumber(latitude!)
            let lonShortString = formatter.stringFromNumber(longitude!)
            textForTableCell = "Near \(latShortString!), \(lonShortString!)"
        }
        
        // Save the search in Core Data
        let newSearch = CoreDataStackManager.sharedInstance.saveNewSearch(postCode, latitude: latitude, longitude: longitude, radius: radius, textForTableCell: textForTableCell)
        self.search = newSearch
        
        // If the search was done using GPS coordinates, start a geocoding process in a different thread to update the string description of the search.
        if let _ = latitude {
            self.geocodeSearchDescription(latitude!, longitude: longitude!)
        }
        
        // Save the schools retrieved from the Api that are associated with the search
        CoreDataStackManager.sharedInstance.saveNewSchools(newSearch, schoolsInfoArray: schoolsInfoArray)
        
        // Moving to the mapView
        self.defreezeScreen(true)
        self.performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: self)
    }
    
    /// MARK: Map delegate functions
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Only displayCurrentUserLocation if we are on case 0, aka 'near me' case
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            displayCurrentUserLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
        displayCurrentUserLocation()
    }
    
    func displayCurrentUserLocation() {
        mapView.showsUserLocation = true
        if let location = locationManager.location {
            if self.forceCenterOnUserLocation == true { // Allows to set the region only once. Then the user is free to change the region and zoom manually without the map refocusing around the user continuously.
                self.forceCenterOnUserLocation = false
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    //// MARK: TableView Delegates Functions & Data
    var previousSearches : [Search] {
        get {
            return CoreDataStackManager.sharedInstance.fetchPreviousSearches()
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Previous Searches"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousSearches.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = previousSearches[indexPath.row].textForTableCell!
        cell.detailTextLabel!.text = "\(previousSearches[indexPath.row].radius!) m"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        search = previousSearches[indexPath.row]
        performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Deleting the search from the CoreDataStackManager
            CoreDataStackManager.sharedInstance.deleteSearchAndItsSchools(previousSearches[indexPath.row])
            
            // Deleting the row from the table
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    /// MARK: Text field delegate functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textFieldOutlet.resignFirstResponder()
        return true
    }
    
    
    /// MARK: General UI Functions
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func defreezeScreen(trueOrFalse: Bool) {
        if trueOrFalse == true {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        sliderOutlet.enabled = trueOrFalse
        segmentedControlOutlet.enabled = trueOrFalse
        longPressOutlet.enabled = trueOrFalse
        textFieldOutlet.enabled = trueOrFalse
        buttonOutlet.enabled = trueOrFalse
        mapView.scrollEnabled = trueOrFalse
        tableView.scrollEnabled = trueOrFalse
        tableView.allowsSelection = trueOrFalse
    }
    
    func showAlertViewController(title: String, errorMessage: String) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: ConstantStrings.sharedInstance.errorOk, style: .Cancel, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! NavigationViewController
        let mapViewController = destinationVC.topViewController as! MapViewController
        mapViewController.search = search
    }
    
    
    /// MARK: Background work dispatched on a different thread
    
    func geocodeSearchDescription(latitude: Double, longitude: Double) {
        var description = ""
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location,
            completionHandler: {(geocodedPlaces: [CLPlacemark]?, geocodingError: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let _ = geocodingError {
                        // No update, current description with coordinates will be used.
                    } else {
                        if let places = geocodedPlaces {
                            if geocodedPlaces!.count == 0 {
                                // No update, current description with coordinates will be used.
                            } else {
                                let place = places.first
                                if let thoroughfare = place!.thoroughfare {
                                    description = "\(thoroughfare)"
                                    if let subLocality = place!.subLocality {
                                        description += ", \(subLocality)"
                                    }
                                } else if let subLocality = place!.subLocality {
                                    description = "\(subLocality)"
                                    if let locality = place!.locality {
                                        description += ", \(locality)"
                                    }
                                } else if let locality = place!.locality {
                                    description += ", \(locality)"
                                } else if let subAdministrativeArea = place!.subAdministrativeArea {
                                    description = "\(subAdministrativeArea)"
                                    if let administrativeArea = place!.administrativeArea {
                                        description += ", \(administrativeArea)"
                                    }
                                } else if let administrativeArea = place!.administrativeArea {
                                    description = "\(administrativeArea)"
                                } else {
                                    // No update, current description with coordinates will be used.
                                }
                            }
                        } else {
                            // No update, current description with coordinates will be used.
                        }
                    }
                    if description != "" { // Only save the new description if the geocoder has provided useful information.
                        CoreDataStackManager.sharedInstance.updateSearchDescription(self.search!, textForTableCell: description)
                    }
                })
        })
    }
}

