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
    let defaults = NSUserDefaults.standardUserDefaults()
    let locationManager = CLLocationManager()
    var searchRadius : Int {
        get {
            return Int(sliderOutlet.value) - Int(sliderOutlet.value) % 10
        }
    }
    var circleOverlay : MKCircle?
    var forceCenterOnNewLocation : Bool?
    var searchToSendToMapViewController : Search?
    var previousSearches : [Search]?
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var previousSearchesLabelOutlet: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewWithMapAndTextField: UIView!
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
        postCodeTextFieldOutlet.returnKeyType = UIReturnKeyType.Search
    }
    
    override func viewWillAppear(animated: Bool) {
        previousSearches = CoreDataStackManager.sharedInstance.fetchPreviousSearches()
        setOutletValues()
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveOutletCurrentValues()
    }
    
    /// MARK: IB Actions
    
    struct segmentedControlIndexes {
        let userLocation    = 0
        let setLocation     = 1
        let postCode        = 2
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
            longPressInstruction.hidden = true
            
            // Prepare view elements for search by user location
            mapView.hidden = false
            locationManager.requestWhenInUseAuthorization()
            
            if let location = locationManager.location {
                
                // Show the user location on the map
                mapView.showsUserLocation = true
                forceCenterOnNewLocation = true
                centerMapOnLocationWithSpan(location, span: 0.06)
                
                // Add the circle on the map
                let coordinates = location.coordinate
                circleOverlay = MKCircle(centerCoordinate: coordinates, radius: Double(sliderOutlet.value))
                mapView.addOverlay(circleOverlay!)
            }
            
        case searchBy.setLocation:
            // Remove view elements needed for search by user location
            mapView.showsUserLocation = false
            
            // Remove view elements needed for search by post code
            postCodeTextFieldOutlet.hidden = true
            postCodeTextFieldOutlet.endEditing(true)
            
            // Prepare view elements for search by set location
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            forceCenterOnNewLocation = false
            if let location = locationManager.location {
                centerMapOnLocationWithSpan(location, span: 0.12)
            }
            longPressInstruction.hidden = false
            
        case searchBy.postCode:
            // Remove view elements needed for search by user location and set location
            mapView.removeOverlays(mapView.overlays)
            
            // Remove view elements needed for search by user location only
            mapView.showsUserLocation = false
            forceCenterOnNewLocation = false
            
            // Remove view elements needed for search by set location only
            mapView.removeAnnotations(mapView.annotations)
            longPressInstruction.hidden = true
            
            // Prepare view elements for search by post code
            postCodeTextFieldOutlet.hidden = false
            postCodeTextFieldOutlet.becomeFirstResponder()
            
        default:
            break; 
        }
    }
    
    // Long press action to add a pin on the map (on searchBy.setLocation only)
    @IBAction func longPressAction(sender: AnyObject) {
        if segmentedControlOutlet.selectedSegmentIndex == searchBy.setLocation {
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
                forceCenterOnNewLocation = true
                centerMapOnLocationWithSpan(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), span: 0.12)
                
                // Hide instruction to do a long-press
                longPressInstruction.hidden = true
            }
        }
    }
    
    @IBAction func sliderMoved(sender: AnyObject) {
        sliderValueLabelOutlet.text = String(searchRadius) + " m"
        if let _ = circleOverlay {
            if segmentedControlOutlet.selectedSegmentIndex == searchBy.userLocation {
                updateCircleOverlay()
                
            } else { // If searching by location or post code
            // Update the circle only if there is an annotation already.
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
        
        if segmentedControlOutlet.selectedSegmentIndex == searchBy.postCode {
            
            guard postCodeTextFieldOutlet.text != "" else {
                defreezeScreen(true)
                showAlertViewController(ConstantStrings.sharedInstance.noPostCodeErrorTitle, errorMessage: ConstantStrings.sharedInstance.noPostCodeErrorMessage)
                return
            }
            
            guard mapView.annotations.count != 0 else {
                self.defreezeScreen(true)
                showAlertViewController(ConstantStrings.sharedInstance.noSelectedLocationErrorTitle, errorMessage: ConstantStrings.sharedInstance.noSelectedLocationErrorMessage)
                return
            }
            
            let latitude = mapView.annotations.first?.coordinate.latitude
            let longitude = mapView.annotations.first?.coordinate.longitude
            searchSchools(postCodeTextFieldOutlet.text, latitude: latitude!, longitude: longitude!, radius: radius)
        }
    }
    
    @IBAction func previousSearchesButtonPressed(sender: AnyObject) {
        if self.previousSearchesButtonOutlet.titleLabel!.text == "Previous searches" {
            self.previousSearchesButtonOutlet.setTitle("Hide", forState: .Normal)
            UIView.animateWithDuration(0.4, animations: { self.view.bounds.offsetInPlace(dx: 0, dy: 250) })
        } else {
            self.previousSearchesButtonOutlet.setTitle("Previous searches", forState: .Normal)
            UIView.animateWithDuration(0.4, animations: { self.view.bounds.offsetInPlace(dx: 0, dy: -250) })
        }
        // Moves by 250 because previousSearchesLabelOutlet height is set to 50, and tableView height is set to 200.
    }
    
    /// MARK: General functions
    
    func searchSchools(postCode: String?, latitude: Double, longitude: Double, radius: Int) {
        accessApi.getSchoolsNearLocation(latitude, longitude: longitude, radius: radius,
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
    
    func saveSearchAndSchools(postCode: String?, latitude: Double, longitude: Double, radius: Int, schoolsInfoArray: [[String: AnyObject]]) {
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
            let latShortString = formatter.stringFromNumber(latitude)
            let lonShortString = formatter.stringFromNumber(longitude)
            textForTableCell = "Near \(latShortString!), \(lonShortString!)"
        }
        
        // Save the search in Core Data
        let newSearch = CoreDataStackManager.sharedInstance.saveNewSearch(postCode, latitude: latitude, longitude: longitude, radius: radius, textForTableCell: textForTableCell)
        self.searchToSendToMapViewController = newSearch
        
        // The search has been created with a String description, but we will create a task in a seperate thread that will update the search description using geocoding if the search was based on GPS Coordintes. This needs to be done a in seperate thread because of the nature of the geocoding process, plus this information will be needed only when the user comes back to the WelcomeViewController, so this does not need to block the main queue.
        if postCode == nil {
            self.geocodeSearchDescriptionInBackground(latitude, longitude: longitude)
        }
        
        // Save the schools retrieved from the Api that are associated with the search
        CoreDataStackManager.sharedInstance.saveNewSchools(newSearch, schoolsInfoArray: schoolsInfoArray)
        
        // Moving to the mapView
        self.defreezeScreen(true)
        self.performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: self)
    }
    
    /// MARK: Text field delegate functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        postCodeTextFieldOutlet.resignFirstResponder()
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
        }
        if textField.text != "" {
            getLocationForPostCode(textField.text!)
        }
        return true
    }
    
    func getLocationForPostCode(postCode: String) {
        accessApi.getPostCodeLocation(postCode,
            completionHandler: {(latitude, longitude, errorString) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    // If there is an error returned from the accessApi class
                    guard errorString == nil else {
                        //self.defreezeScreen(true)
                        self.showAlertViewController(ConstantStrings.sharedInstance.errorTitle, errorMessage: errorString!)
                        return
                    }
                    
                    let pinAnnotation = MKPointAnnotation()
                    let coordinates = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                    pinAnnotation.coordinate = coordinates
                    self.mapView.addAnnotation(pinAnnotation)
                    
                    // Add the circle on the map
                    self.circleOverlay = MKCircle(centerCoordinate: coordinates, radius: Double(self.sliderOutlet.value))
                    self.mapView.addOverlay(self.circleOverlay!)
                    self.forceCenterOnNewLocation = true
                    self.centerMapOnLocationWithSpan(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), span: 0.12)
                })
        })
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
}