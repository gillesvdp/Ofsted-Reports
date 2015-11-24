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

class WelcomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    let accessApi = AccessAPI()
    let locationManager = CLLocationManager()
    var searchRadius : Int {
        get {
            return Int(sliderOutlet.value) - Int(sliderOutlet.value) % 100
        }
    }
    var forceCenterOnUserLocation : Bool!
    
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sliderOutlet: UISlider!
    @IBOutlet weak var sliderValueLabelOutlet: UILabel!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var longPressOutlet: UILongPressGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ConstantStrings.sharedInstance.welcomeViewControllerTitle
        tableView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    override func viewWillAppear(animated: Bool) {
        mapView.hidden = true
        mapView.showsUserLocation = false
        segmentedControlOutlet.enabled = true
        segmentedControlOutlet.selectedSegmentIndex = 1
        forceCenterOnUserLocation = true
        longPressOutlet.enabled = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        switch segmentedControlOutlet.selectedSegmentIndex {
        case 0:
            // My location
            textFieldOutlet.hidden = true
            mapView.hidden = false
            longPressOutlet.enabled = false
            
            // Request the authorization to use the user's current location
            locationManager.requestWhenInUseAuthorization()
            
            // Function used only if the user has already given authorization.
            // If the user gives the authorisation for the first time, the function is executed in the didChangeAuthorizationStatus function because of asynchronous execution of 'requestWhenInUseAuthrorization'.
            displayCurrentUserLocation()
            
        case 1:
            // Post Code
            textFieldOutlet.hidden = false
            forceCenterOnUserLocation = true
            mapView.hidden = true
            
        case 2:
            // Other location
            textFieldOutlet.hidden = true
            forceCenterOnUserLocation = true
            mapView.hidden = false
            
            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation = false
            longPressOutlet.enabled = true
            
        default:
            break; 
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        displayCurrentUserLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
        displayCurrentUserLocation()
        displayRadiusCircle()
    }
    
    func displayCurrentUserLocation() {
        mapView.showsUserLocation = true
        if let location = locationManager.location {
            if self.forceCenterOnUserLocation == true { // Allows to set the region only once. Then the user is free to change the region and zoom manually without the code resetting it continuously.
                self.forceCenterOnUserLocation = false
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func displayRadiusCircle() {
        /*
        var center = CLLocationCoordinate2D()
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            if let location = locationManager.location {
                center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }
        if segmentedControlOutlet.selectedSegmentIndex == 2 {
            if let annotation = mapView.annotations.first {
                center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            }
        }
        let rad = CLLocationDistance(searchRadius)
        let circle = MKCircle(centerCoordinate: center, radius: rad)
        mapView.addOverlay(circle)
        let renderer = MKOverlayRenderer(overlay: circle)
        renderer.alpha = 0.5
        renderer.setNeedsDisplay()
        */
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
            print(newCoordinates)
        }
    }
    
    
    @IBAction func sliderMoved(sender: AnyObject) {
        sliderValueLabelOutlet.text = String(searchRadius) + " m"
        displayRadiusCircle()
    }
    
    
    @IBAction func buttonPressed(sender: AnyObject) {
        activityIndicator.startAnimating()
        segmentedControlOutlet.enabled = false
        let radius = searchRadius
        
        // Search by Current Location
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            guard locationManager.location == nil else {
                segmentedControlOutlet.enabled = true
                activityIndicator.stopAnimating()
                showAlertViewController(ConstantStrings.sharedInstance.noUserLocationErrorMessage)
                return
            }
            
            // Saving the newSearch
            let latitude = locationManager.location!.coordinate.latitude
            let longitude = locationManager.location!.coordinate.longitude
            
            searchSchoolsByCoordinates(latitude, longitude: longitude, radius: radius)
        }
        
        // Search by Post Code
        if segmentedControlOutlet.selectedSegmentIndex == 1 {
            guard textFieldOutlet.text != "" else {
                segmentedControlOutlet.enabled = true
                activityIndicator.stopAnimating()
                showAlertViewController(ConstantStrings.sharedInstance.noPostCodeErrorMessage)
                return
            }
            
            // Searching for schools through postCode through the Api
            accessApi.getWithPostCode(textFieldOutlet.text!, radius: radius,
            completionHandler: {(schoolsInfoArray, errorString) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                    guard errorString == nil else {
                        self.showAlertViewController(errorString!)
                        return
                    }
                    
                    guard schoolsInfoArray!.count != 0 else {
                        self.showAlertViewController(ConstantStrings.sharedInstance.noSchoolsInAreaError)
                        return
                    }
                    
                    // Saving the newSearch
                    let newSearch = CoreDataStackManager.sharedInstance.saveNewSearchByPostcode(self.textFieldOutlet.text!, radius: radius)
                    
                    // Saving the schools retrieved from the Api
                    CoreDataStackManager.sharedInstance.saveNewSchools(newSearch, schoolsInfoArray: schoolsInfoArray!)
            
                    // Moving to the mapView
                    self.performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: self)
                })
            })
        }
        
        // Search by Other location
        if segmentedControlOutlet.selectedSegmentIndex == 2 {
            guard mapView.annotations.count != 0 else {
                segmentedControlOutlet.enabled = true
                activityIndicator.stopAnimating()
                showAlertViewController(ConstantStrings.sharedInstance.noSelectedLocationErrorMessage)
                return
            }
            
            // Saving the newSearch
            let latitude = mapView.annotations.first?.coordinate.latitude
            let longitude = mapView.annotations.first?.coordinate.longitude
            
            searchSchoolsByCoordinates(latitude!, longitude: longitude!, radius: radius)
        }
    }
    
    func searchSchoolsByCoordinates(latitude: Double, longitude: Double, radius: Int) {
        accessApi.getWithCoordinates(latitude, longitude: longitude, radius: radius,
            completionHandler: {(schoolsInfoArray, errorString) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                    guard errorString == nil else {
                        self.showAlertViewController(errorString!)
                        return
                    }
                    
                    guard schoolsInfoArray!.count != 0 else {
                        self.showAlertViewController(ConstantStrings.sharedInstance.noSchoolsInAreaError)
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        self.longPressOutlet.enabled = true
                        return
                    }
                    
                    // Saving the search
                    let newSearch = CoreDataStackManager.sharedInstance.saveNewSearchByLocation(latitude, longitude: longitude, radius: radius)
                    
                    // Saving the schools retrieved from the Api
                    CoreDataStackManager.sharedInstance.saveNewSchools(newSearch, schoolsInfoArray: schoolsInfoArray!)
                    
                    // Moving to the mapView
                    self.performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: self)
                })
        })
    }
    
    
    func showAlertViewController(errorMessage: String) {
        let alert = UIAlertController(title: ConstantStrings.sharedInstance.errorTitle, message: errorMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: ConstantStrings.sharedInstance.errorOk, style: .Cancel, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //// TableView Functions
    var previousSearches : [Search] {
        get {
            return CoreDataStackManager.sharedInstance.fetchPreviousSearches()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousSearches.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        if previousSearches[indexPath.row].postCode != nil {
            cell.textLabel!.text = previousSearches[indexPath.row].postCode! + ", " + String(previousSearches[indexPath.row].radius!)
        } else {
            cell.textLabel!.text = String(previousSearches[indexPath.row].latitude!) + ", " + String(previousSearches[indexPath.row].longitude!) + ", " + String(previousSearches[indexPath.row].radius!) + " m"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // let destinationVC = segue.destinationViewController as! UINavigationController
        
        // destinationVC.search = newSearch
        
    }
}

