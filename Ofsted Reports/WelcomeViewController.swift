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
    
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sliderOutlet: UISlider!
    @IBOutlet weak var sliderValueLabelOutlet: UILabel!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ConstantStrings.sharedInstance.welcomeViewControllerTitle
        tableView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    override func viewWillAppear(animated: Bool) {
        mapView.hidden = true
        segmentedControlOutlet.enabled = true
        segmentedControlOutlet.selectedSegmentIndex = 1
    }
    
    override func viewDidDisappear(animated: Bool) {
        mapView.showsUserLocation = false
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        switch segmentedControlOutlet.selectedSegmentIndex {
        case 0:
            // Current location
            mapView.hidden = false
            textFieldOutlet.hidden = true
            
            // Request the authorization to use the user's current location
            locationManager.requestWhenInUseAuthorization()
            
            // Function used only if the user has already given authorization.
            // If the user gives the authorisation for the first time, the function is executed in the didChangeAuthorizationStatus function because of asynchronous execution of 'requestWhenInUseAuthrorization'.
            displayCurrentUserLocation()
            
        case 1:
            // Post Code
            mapView.hidden = true
            textFieldOutlet.hidden = false
        case 2:
            // Other location
            mapView.hidden = false
            textFieldOutlet.hidden = true
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
    }
    
    func displayCurrentUserLocation() {
        mapView.showsUserLocation = true
        if let location = locationManager.location {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func sliderMoved(sender: AnyObject) {
        sliderValueLabelOutlet.text = String(searchRadius) + " m"
    }
    
    
    @IBAction func buttonPressed(sender: AnyObject) {
        activityIndicator.startAnimating()
        segmentedControlOutlet.enabled = false
        let radius = searchRadius
        
        // Search by Current Location
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            guard locationManager.location == nil else {
                segmentedControlOutlet.enabled = true
                showAlertViewController(ConstantStrings.sharedInstance.noLocationErrorMessage)
                return
            }
            
            // Saving the newSearch
            let latitude = locationManager.location!.coordinate.latitude
            let longitude = locationManager.location!.coordinate.longitude
            
            let newSearch = CoreDataStackManager.sharedInstance.saveNewSearchByLocation(latitude, longitude: longitude, radius: radius)
            
            searchSchoolsByCoordinates(newSearch, latitude: latitude, longitude: longitude, radius: radius)
        }
        
        // Search by Post Code
        if segmentedControlOutlet.selectedSegmentIndex == 1 {
            guard textFieldOutlet.text != "" else {
                segmentedControlOutlet.enabled = true
                showAlertViewController(ConstantStrings.sharedInstance.noPostCodeErrorMessage)
                return
            }
            
            // Saving the newSearch
            let newSearch = CoreDataStackManager.sharedInstance.saveNewSearchByPostcode(self.textFieldOutlet.text!, radius: radius)
            
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
            
                    // Saving the schools retrieved from the Api
                    CoreDataStackManager.sharedInstance.saveNewSchools(newSearch, schoolsInfoArray: schoolsInfoArray!)
            
                    // Moving to the mapView
                    self.performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: self)
                })
            })
        }
        
        // Search by Other location
        // if
        
        
        
    }
    
    func searchSchoolsByCoordinates(newSearch: Search, latitude: Double, longitude: Double, radius: Int) {
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
                        return
                    }
                    
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
        if previousSearches[indexPath.row].postCode != nil || previousSearches[indexPath.row].postCode != "" {
            cell.textLabel!.text = previousSearches[indexPath.row].postCode! + ", " + String(previousSearches[indexPath.row].radius!)
        } else {
            cell.textLabel!.text = String(previousSearches[indexPath.row].latitude) + ", " + String(previousSearches[indexPath.row].longitude) + ", " + String(previousSearches[indexPath.row].radius!) + " m"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(ConstantStrings.sharedInstance.showMap, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! MapViewController
        
        if let _ = sender as? UIButton {
            if segmentedControlOutlet.selectedSegmentIndex == 0 { // User's current location
                
            }
            if segmentedControlOutlet.selectedSegmentIndex == 1 { // Postcode
                destinationVC.viewTitle = textFieldOutlet.text!
            }
            if segmentedControlOutlet.selectedSegmentIndex == 2 { // Other location
                
            }
        }
        if let cell = sender as? UITableViewCell {
            destinationVC.viewTitle = cell.textLabel!.text!
        }

        // destinationVC.search = newSearch
        
    }
}

