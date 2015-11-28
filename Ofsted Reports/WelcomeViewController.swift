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
    var forceCenterOnUserLocation : Bool?
    var searchToSendToMapViewController : Search?
    var previousSearches : [Search]?
    let defaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var previousSearchesLabelOutlet: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postCodeTextFieldOutlet: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sliderOutlet: UISlider!
    @IBOutlet weak var sliderValueLabelOutlet: UILabel!
    @IBOutlet weak var previousSearchesButtonOutlet: UIButton!
    @IBOutlet weak var newSearchButtonOutlet: UIButton!
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
        postCodeTextFieldOutlet.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    override func viewWillAppear(animated: Bool) {
        previousSearches = CoreDataStackManager.sharedInstance.fetchPreviousSearches()
        setOutletValues()
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveOutletCurrentValues()
    }
    
    func setOutletValues() {
        // If there are saved values for welcomeScreen outlets, let's load these.
        // These values typically exist if the user is coming back from the map, and trying to do a new search.
        // In this case, the welcome screen is the same way the user left it, so as to provide a seemless experience.
        
        guard defaults.valueForKey("welcomeScreenOutletValues") == nil else {
            let savedOutledValues = defaults.valueForKey("welcomeScreenOutletValues") as! [String: AnyObject]
            
            segmentedControlOutlet.enabled = savedOutledValues["segmentedControlIsEnabled"] as! Bool
            segmentedControlOutlet.selectedSegmentIndex = savedOutledValues["segmentedControlSelectedIndex"] as! Int
            
            mapView.hidden = savedOutledValues["mapViewIsHidden"] as! Bool
            mapView.showsUserLocation = savedOutledValues["mapViewShowsUserLocation"] as! Bool
            
            // Note the map content is upated upon reload the screen:
            // If showing user location: the map refocuses on the user location, and draws a circle.
            // If showing the map to select a location, the map is shown empty: no pins and no circle, but instruction to long-press is on.
            forceCenterOnUserLocation = false
            if segmentedControlOutlet.selectedSegmentIndex == searchBy.userLocation {
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
            postCodeTextFieldOutlet.hidden = savedOutledValues["postCodeTextFieldOutletIsHidden"] as! Bool
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
        postCodeTextFieldOutlet.hidden = false
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
            "postCodeTextFieldOutletIsHidden" : postCodeTextFieldOutlet.hidden,
            "sliderValueLabelOutletText" : sliderValueLabelOutlet.text!,
            "sliderOutletValue" : sliderOutlet.value
        ]
        defaults.setValue(welcomeScreenOutletValues, forKey: "welcomeScreenOutletValues")
    }
    
    /// MARK: IB Actions
    
    struct segmentedControlIndexes {
        let userLocation    = 0
        let postCode        = 1
        let setLocation     = 2
    }
    let searchBy = segmentedControlIndexes()
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        
        switch segmentedControlOutlet.selectedSegmentIndex {
            
        case searchBy.userLocation:
            // Remove view elements needed for search by post code
            postCodeTextFieldOutlet.hidden = true
            postCodeTextFieldOutlet.endEditing(true)
            
            // Remove view elements needed for search by set location
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            longPressOutlet.enabled = false
            longPressInstruction.hidden = true
            
            // Prepare view elements for search by user location
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
            
        case searchBy.postCode:
            // Remove view elements needed for search by user location and set location
            mapView.removeOverlays(mapView.overlays)
            
            // Remove view elements needed for search by user location only
            mapView.hidden = true
            
            // Remove view elements needed for search by set location only
            mapView.removeAnnotations(mapView.annotations)
            mapView.hidden = true
            longPressOutlet.enabled = false
            longPressInstruction.hidden = true
            
            // Prepare view elements for search by post code
            postCodeTextFieldOutlet.hidden = false
            postCodeTextFieldOutlet.becomeFirstResponder()
            
        case searchBy.setLocation:
            // Remove view elements needed for search by user location
            mapView.showsUserLocation = false
            
            // Remove view elements needed for search by post code
            postCodeTextFieldOutlet.hidden = true
            postCodeTextFieldOutlet.endEditing(true)
            
            // Prepare view elements for search by set location
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
            
            // Hide instruction to do a long-press
            longPressInstruction.hidden = true
        }
    }
    
    @IBAction func sliderMoved(sender: AnyObject) {
        sliderValueLabelOutlet.text = String(searchRadius) + " m"
        if let _ = circleOverlay {
            // If showing the user location
            if segmentedControlOutlet.selectedSegmentIndex == searchBy.userLocation {
                updateCircleOverlay()
            }
            
            // If showing a selected location, show the circle only if there is an annotation already.
            if segmentedControlOutlet.selectedSegmentIndex == searchBy.setLocation {
                if mapView.annotations.count > 0 {
                    updateCircleOverlay()
                }
            }
        }
    }
    
    @IBAction func newSearchButtonPressed(sender: AnyObject) {
        defreezeScreen(false) // = disable screen outlets
        activityIndicator.startAnimating()
        let radius = searchRadius
        
        if segmentedControlOutlet.selectedSegmentIndex == searchBy.userLocation {
            guard locationManager.location != nil else {
                defreezeScreen(true)
                showAlertViewController(ConstantStrings.sharedInstance.noUserLocationErrorTitle, errorMessage: ConstantStrings.sharedInstance.noUserLocationErrorMessage)
                return
            }
            
            let latitude = locationManager.location!.coordinate.latitude
            let longitude = locationManager.location!.coordinate.longitude
            searchSchools(nil, latitude: latitude, longitude: longitude, radius: radius)
        }
        
        if segmentedControlOutlet.selectedSegmentIndex == searchBy.postCode {
            guard postCodeTextFieldOutlet.text != "" else {
                defreezeScreen(true)
                showAlertViewController(ConstantStrings.sharedInstance.noPostCodeErrorTitle, errorMessage: ConstantStrings.sharedInstance.noPostCodeErrorMessage)
                return
            }
            
            searchSchools(postCodeTextFieldOutlet.text!, latitude: nil, longitude: nil, radius: radius)
        }
        
        if segmentedControlOutlet.selectedSegmentIndex == searchBy.setLocation {
            guard mapView.annotations.count != 0 else {
                self.defreezeScreen(true)
                showAlertViewController(ConstantStrings.sharedInstance.noSelectedLocationErrorTitle, errorMessage: ConstantStrings.sharedInstance.noSelectedLocationErrorMessage)
                return
            }
            
            let latitude = mapView.annotations.first?.coordinate.latitude
            let longitude = mapView.annotations.first?.coordinate.longitude
            searchSchools(nil, latitude: latitude!, longitude: longitude!, radius: radius)
        }
    }
    
    @IBAction func previousSearchesButtonPressed(sender: AnyObject) {
        UIView.animateWithDuration(0.4, animations: {
            if self.previousSearchesButtonOutlet.titleLabel!.text == "Previous searches" {
                self.previousSearchesButtonOutlet.setTitle("Hide", forState: .Normal)
                self.view.bounds.offsetInPlace(dx: 0, dy: 250)
                
            } else {
                self.previousSearchesButtonOutlet.setTitle("Previous searches", forState: .Normal)
                self.view.bounds.offsetInPlace(dx: 0, dy: -250)
            }
        })
        // Moves by 250 because previousSearchesLabelOutlet height is set to 50, and tableView height is set to 200.
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
        // Preparing to save the search (first: we generate a String description for the search)
        var textForTableCell = String()
        if let _ = postCode {
            // PostCode search: Desctription will be the postcode in uppercase
            textForTableCell = postCode!.uppercaseString
        } else {
            // GPS Search: Description will be in the format 'Near 0.00, 0.00' 
            // (otherwise there would be too many decimal digits to be displayed in a label)
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            formatter.maximumFractionDigits = 2
            let latShortString = formatter.stringFromNumber(latitude!)
            let lonShortString = formatter.stringFromNumber(longitude!)
            textForTableCell = "Near \(latShortString!), \(lonShortString!)"
        }
        
        // Save the search in Core Data
        let newSearch = CoreDataStackManager.sharedInstance.saveNewSearch(postCode, latitude: latitude, longitude: longitude, radius: radius, textForTableCell: textForTableCell)
        self.searchToSendToMapViewController = newSearch
        
        // The search has been created with a String description, but we will create a task in a seperate thread that will update the search description using geocoding if the search was based on GPS Coordintes. This needs to be done a in seperate thread because of the nature of the geocoding process, plus this information will be needed only when the user comes back to the WelcomeViewController, so this does not need to block the main queue.
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
        print("Location manager failed with error: \(error)")
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
    
    //// MARK: TableView Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousSearches!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = previousSearches![indexPath.row].textForTableCell!
        cell.detailTextLabel!.text = "\(previousSearches![indexPath.row].radius!) m"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchToSendToMapViewController = previousSearches![indexPath.row]
        performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Deleting the search from the CoreDataStackManager
            CoreDataStackManager.sharedInstance.deleteSearchAndItsSchools(previousSearches![indexPath.row])
            
            // Refresh content of previousSearches variable in this class (required, as this is used to populate the table)
            previousSearches = CoreDataStackManager.sharedInstance.fetchPreviousSearches()
            
            // Deleting the row from the table
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    /// MARK: Text field delegate functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        postCodeTextFieldOutlet.resignFirstResponder()
        return true
    }
    
    /// MARK: General UI Functions
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func defreezeScreen(trueOrFalse: Bool) {
        // true = defreeze screen, i.e. enable outlets
        // false = freeze screen, i.e. disable outlets
        
        if trueOrFalse == true {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        sliderOutlet.enabled = trueOrFalse
        segmentedControlOutlet.enabled = trueOrFalse
        longPressOutlet.enabled = trueOrFalse
        postCodeTextFieldOutlet.enabled = trueOrFalse
        previousSearchesButtonOutlet.enabled = trueOrFalse
        newSearchButtonOutlet.enabled = trueOrFalse
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
        mapViewController.search = searchToSendToMapViewController
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
                        CoreDataStackManager.sharedInstance.updateSearchDescription(self.searchToSendToMapViewController!, textForTableCell: updatedDescription)
                    }
                })
        })
    }
}