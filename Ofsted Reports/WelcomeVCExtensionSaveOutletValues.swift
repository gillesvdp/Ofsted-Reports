//
//  WelcomeVCExtensionSaveOutletValues.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/30/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import MapKit

extension WelcomeViewController {
    
    // The 2 functions in this extension are used to save the outlet values when the user navigates inside the app,
    // and to set the outletValues when the WelcomeVC appears, either on app launch or coming back from a search.
    

    func setOutletValues() {
        
        // General reset
        segmentedControlOutlet.enabled = true
        longPressOutlet.enabled = true
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        // Load saved values, if any
        if defaults.valueForKey("welcomeScreenOutletValues") != nil {
            let savedOutledValues = defaults.valueForKey("welcomeScreenOutletValues") as! [String: AnyObject]
            
            segmentedControlOutlet.selectedSegmentIndex = savedOutledValues["segmentedControlSelectedIndex"] as! Int
            if segmentedControlOutlet.selectedSegmentIndex == searchBy.userLocation {
                if let _ = locationManager.location {
                    forceCenterOnNewLocation = true
                    let coordinates = locationManager.location!.coordinate
                    mapView.showsUserLocation = true
                    circleOverlay = MKCircle(centerCoordinate: coordinates, radius: Double(sliderOutlet.value))
                    mapView.addOverlay(circleOverlay!)
                }
                
                longPressInstruction.hidden = true
                
                postCodeTextFieldOutlet.hidden = true
                
            }
            if segmentedControlOutlet.selectedSegmentIndex == searchBy.setLocation {
                mapView.showsUserLocation = false
                
                longPressInstruction.hidden = false
                forceCenterOnNewLocation = false
                
                postCodeTextFieldOutlet.hidden = true

            }
            if segmentedControlOutlet.selectedSegmentIndex == searchBy.postCode {
                mapView.showsUserLocation = false
                
                longPressInstruction.hidden = true
                forceCenterOnNewLocation = false
                
                postCodeTextFieldOutlet.hidden = false
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
            
            sliderValueLabelOutlet.text = savedOutledValues["sliderValueLabelOutletText"] as? String
            sliderOutlet.value = savedOutledValues["sliderOutletValue"] as! Float
        
        // Otherwise, load standard values
        } else {
            segmentedControlOutlet.selectedSegmentIndex = searchBy.setLocation
            mapView.showsUserLocation = false
            forceCenterOnNewLocation = true
            
            longPressInstruction.hidden = false
            
            postCodeTextFieldOutlet.hidden = true
        }
    }
    
    func saveOutletCurrentValues() {
        let welcomeScreenOutletValues : [String: AnyObject] = [
            "segmentedControlSelectedIndex" : segmentedControlOutlet.selectedSegmentIndex,
            
            "mapViewRegion" : [
                "latitude" : mapView.region.center.latitude,
                "longitude" : mapView.region.center.longitude,
                "latitudeSpan" : mapView.region.span.latitudeDelta,
                "longitudeSpan" : mapView.region.span.longitudeDelta
            ],
            
            "sliderValueLabelOutletText" : sliderValueLabelOutlet.text!,
            "sliderOutletValue" : sliderOutlet.value
        ]
        defaults.setValue(welcomeScreenOutletValues, forKey: "welcomeScreenOutletValues")
    }
}