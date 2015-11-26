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

class WelcomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {

    /// MARK: Variables and constants
    let accessApi = AccessAPI()
    let locationManager = CLLocationManager()
    var searchRadius : Int {
        get {
            return Int(sliderOutlet.value) - Int(sliderOutlet.value) % 10
        }
    }
    var circleOverlay : MKCircle?
    var forceCenterOnUserLocation : Bool!
    var search : Search?
    let defaults = NSUserDefaults.standardUserDefaults()
    
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
        mapView.delegate = self
        textFieldOutlet.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    override func viewWillAppear(animated: Bool) {
        setOutletValues()
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveOutletCurrentValues()
    }
    
    func setOutletValues() {
        // If there are saved values for welcomeScreen outlets, let's load these.
        // These values typically exist if the user is coming back from the map, and trying to do a new search.
        // In this case, the welcome screen is set-up exactly the same way the user left it, so as to provide a seemless experience.
        
        guard defaults.valueForKey("welcomeScreenOutletValues") == nil else {
            let savedOutledValues = defaults.valueForKey("welcomeScreenOutletValues") as! [String: AnyObject]
            
            segmentedControlOutlet.enabled = savedOutledValues["segmentedControlIsEnabled"] as! Bool
            segmentedControlOutlet.selectedSegmentIndex = savedOutledValues["segmentedControlSelectedIndex"] as! Int
            
            mapView.hidden = savedOutledValues["mapViewIsHidden"] as! Bool
            mapView.showsUserLocation = savedOutledValues["mapViewShowsUserLocation"] as! Bool
            forceCenterOnUserLocation = false
            
            if segmentedControlOutlet.selectedSegmentIndex == 0 {
                if let _ = locationManager.location {
                    forceCenterOnUserLocation = true
                    let coordinates = locationManager.location!.coordinate
                    circleOverlay = MKCircle(centerCoordinate: coordinates, radius: Double(sliderOutlet.value))
                    mapView.addOverlay(circleOverlay!)
                }
            }
            
            let mapViewRegion = savedOutledValues["mapViewRegion"] as! [String: Double]
            let center = CLLocationCoordinate2D(
                latitude: mapViewRegion["latitude"]!,
                longitude: mapViewRegion["longitude"]!
            )
            let span = MKCoordinateSpan(
                latitudeDelta: mapViewRegion["latitudeSpan"]!,
                longitudeDelta: mapViewRegion["latitudeSpan"]!
            )
            mapView.region = MKCoordinateRegion(center: center, span: span)
            
            longPressOutlet.enabled = savedOutledValues["longPressOutletIsEnabled"] as! Bool
            longPressInstruction.hidden = savedOutledValues["longPressInstructionIsHidden"] as! Bool
            
            textFieldOutlet.hidden = savedOutledValues["textFieldOutletIsHidden"] as! Bool
            sliderValueLabelOutlet.text = savedOutledValues["sliderValueLabelOutletText"] as? String
            sliderOutlet.value = savedOutledValues["sliderOutletValue"] as! Float
            return
        }
        
        // Otherwise, load standard values
        segmentedControlOutlet.enabled = true
        segmentedControlOutlet.selectedSegmentIndex = 1
        mapView.hidden = true
        mapView.showsUserLocation = false
        forceCenterOnUserLocation = true
        longPressOutlet.enabled = false
        longPressInstruction.hidden = true
        textFieldOutlet.hidden = false
    }
    
    func saveOutletCurrentValues() {
        let welcomeScreenOutletValues : [String: AnyObject] = [
            "segmentedControlIsEnabled" : segmentedControlOutlet.enabled,
            "segmentedControlSelectedIndex" : segmentedControlOutlet.selectedSegmentIndex,
            "mapViewIsHidden" : mapView.hidden,
            "mapViewShowsUserLocation" : mapView.showsUserLocation,
            
            "mapViewRegion" : [
                "latitude" : mapView.region.center.latitude,
                "longitude" : mapView.region.center.longitude,
                "latitudeSpan" : mapView.region.span.latitudeDelta,
                "longitudeSpan" : mapView.region.span.longitudeDelta
            ],
            
            "longPressOutletIsEnabled" : longPressOutlet.enabled,
            "longPressInstructionIsHidden" : longPressInstruction.hidden,
            "textFieldOutletIsHidden" : textFieldOutlet.hidden,
            "sliderValueLabelOutletText" : sliderValueLabelOutlet.text!,
            "sliderOutletValue" : sliderOutlet.value
        ]
        defaults.setValue(welcomeScreenOutletValues, forKey: "welcomeScreenOutletValues")
    }
    
    
    /// MARK: IB Actions
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        switch segmentedControlOutlet.selectedSegmentIndex {
        case 0: // Search based on my location
            
            // Remove view elements needed for case 1
            textFieldOutlet.hidden = true
            textFieldOutlet.endEditing(true)
            
            // Remove view elements needed for case 2
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            longPressOutlet.enabled = false
            longPressInstruction.hidden = true
            
            // Prepare view elements for case 0
            mapView.hidden = false
            locationManager.requestWhenInUseAuthorization()
            
            if let location = locationManager.location {
                
                // Show the user location on the map
                mapView.showsUserLocation = true
                forceCenterOnUserLocation = true
                centerMapOnCurrentUserLocation(0.06)
                
                // Add the circle on the map
                let coordinates = location.coordinate
                circleOverlay = MKCircle(centerCoordinate: coordinates, radius: Double(sliderOutlet.value))
                mapView.addOverlay(circleOverlay!)
            }
            
        case 1: // Search by Post Code
            // Remove view elements needed for case 0 and 2
            mapView.removeOverlays(mapView.overlays)
            
            // Remove view elements needed for case 0 only
            mapView.hidden = true
            
            // Remove view elements needed for case 2 only
            mapView.removeAnnotations(mapView.annotations)
            mapView.hidden = true
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
            
            // Prepare view elements for case 2
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            mapView.hidden = false
            forceCenterOnUserLocation = true
            centerMapOnCurrentUserLocation(0.12)
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
            
            // Add the pin annotation on the map
            let touchPoint = longPressOutlet.locationInView(mapView)
            let coordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = coordinates
            mapView.addAnnotation(pinAnnotation)
            
            // Add the circle on the map
            circleOverlay = MKCircle(centerCoordinate: coordinates, radius: Double(sliderOutlet.value))
            mapView.addOverlay(circleOverlay!)
        }
    }
    
    @IBAction func sliderMoved(sender: AnyObject) {
        sliderValueLabelOutlet.text = String(searchRadius) + " m"
        if let _ = circleOverlay {
            // If showing the user location
            if segmentedControlOutlet.selectedSegmentIndex == 0 {
                updateCircleOverlay()
            }
            
            // If showing a selected location, show the circle only if there is an annotation already.
            if segmentedControlOutlet.selectedSegmentIndex == 2 {
                if mapView.annotations.count > 0 {
                    updateCircleOverlay()
                }
            }
        }
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
        // Preparing to save the search (first: we generat a basic string description for the search)
        var textForTableCell = String()
        if let _ = postCode {
            textForTableCell = postCode!.uppercaseString // Formatting the search in upper case
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
        
        // The search has been created with a basic description, but we will create a task in a seperate thread that will clean-up the description. This needs to be done a in seperate thread because a geocoding process will be used in the case of a search based on GPS Coordinates.
        if let _ = latitude {
            if let _ = longitude {
                self.geocodeSearchDescriptionInBackground(latitude!, longitude: longitude!)
            }
        }
        
        // Save the schools retrieved from the Api that are associated with the search
        CoreDataStackManager.sharedInstance.saveNewSchools(newSearch, schoolsInfoArray: schoolsInfoArray)
        
        // Moving to the mapView
        self.defreezeScreen(true)
        self.performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: self)
    }
    
    /// MARK: Map functions
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            centerMapOnCurrentUserLocation(0.06)
            mapView.showsUserLocation = true
        } else if segmentedControlOutlet.selectedSegmentIndex == 2 {
            centerMapOnCurrentUserLocation(0.12)
            mapView.showsUserLocation = false
        }
        updateCircleOverlay()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            centerMapOnCurrentUserLocation(0.06)
        } else if segmentedControlOutlet.selectedSegmentIndex == 2 {
            centerMapOnCurrentUserLocation(0.12)
        }
    }
    
    func centerMapOnCurrentUserLocation(span: Double) {
        if let location = locationManager.location {
            if let _ = forceCenterOnUserLocation {
                if self.forceCenterOnUserLocation == true {
                    // Above if condition allows to set the region only once. Then the user is free to change the region and zoom manually without the map refocusing around the user continuously.
                    
                    self.forceCenterOnUserLocation = false
                    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
                    mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.redColor()
        circleRenderer.fillColor = UIColor.orangeColor()
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
    
    func updateCircleOverlay() {
        
        var coordinates : CLLocationCoordinate2D?
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            if let _ = locationManager.location {
                coordinates = locationManager.location?.coordinate
            }
            
        }
        if segmentedControlOutlet.selectedSegmentIndex == 2 {
            if mapView.annotations.count > 0 {
                if let _ = circleOverlay {
                    coordinates = circleOverlay!.coordinate
                }
            }
        }
        
        if let _ = coordinates {
            let updatedCircleOverlay = MKCircle(centerCoordinate: coordinates!, radius: Double(sliderOutlet.value))
            mapView.addOverlay(updatedCircleOverlay)
            mapView.removeOverlays([mapView.overlays.first!])
            
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
    
    func geocodeSearchDescriptionInBackground(latitude: Double, longitude: Double) {
        var updatedDescription = ""
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
                                    updatedDescription = "\(thoroughfare)"
                                    if let subLocality = place!.subLocality {
                                        updatedDescription += ", \(subLocality)"
                                    }
                                } else if let subLocality = place!.subLocality {
                                    updatedDescription = "\(subLocality)"
                                    if let locality = place!.locality {
                                        updatedDescription += ", \(locality)"
                                    }
                                } else if let locality = place!.locality {
                                    updatedDescription += ", \(locality)"
                                } else if let subAdministrativeArea = place!.subAdministrativeArea {
                                    updatedDescription = "\(subAdministrativeArea)"
                                    if let administrativeArea = place!.administrativeArea {
                                        updatedDescription += ", \(administrativeArea)"
                                    }
                                } else if let administrativeArea = place!.administrativeArea {
                                    updatedDescription = "\(administrativeArea)"
                                } else {
                                    // No update, current description with coordinates will be used.
                                }
                            }
                        } else {
                            // No update, current description with coordinates will be used.
                        }
                    }
                    if updatedDescription != "" { // Only save the new description if the geocoder has provided useful information.
                        CoreDataStackManager.sharedInstance.updateSearchDescription(self.search!, textForTableCell: updatedDescription)
                    }
                })
        })
    }
}

