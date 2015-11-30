//
//  WelcomeVCExtensionMapFuncs.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/30/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import MapKit

extension WelcomeViewController {
    
    /// MARK: Map functions
   
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if segmentedControlOutlet.selectedSegmentIndex == searchBy.userLocation {
            if let location = locationManager.location {
                centerMapOnLocationWithSpan(location, span: 0.06)
                mapView.showsUserLocation = true
                updateCircleOverlay()
            }
        } else if segmentedControlOutlet.selectedSegmentIndex == searchBy.setLocation {
            if let location = locationManager.location {
                centerMapOnLocationWithSpan(location, span: 0.12)
                mapView.showsUserLocation = false
                updateCircleOverlay()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed with error: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
        if segmentedControlOutlet.selectedSegmentIndex == searchBy.userLocation {
            if let location = locationManager.location {
                centerMapOnLocationWithSpan(location, span: 0.06)
            }
        } else if segmentedControlOutlet.selectedSegmentIndex == searchBy.setLocation {
            if let location = locationManager.location {
                centerMapOnLocationWithSpan(location, span: 0.12)
            }
        }
    }
    
    func centerMapOnLocationWithSpan(location: CLLocation, span: Double) {
        if let _ = forceCenterOnNewLocation {
            if self.forceCenterOnNewLocation == true {
                // Above if condition allows to set the region only once. Then the user is free to change the region and zoom manually without the map refocusing around the user continuously.
                self.forceCenterOnNewLocation = false
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
                mapView.setRegion(region, animated: true)
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
        if segmentedControlOutlet.selectedSegmentIndex == searchBy.userLocation {
            if let _ = locationManager.location {
                coordinates = locationManager.location?.coordinate
            }
        } else { // by set location of postcode
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
}