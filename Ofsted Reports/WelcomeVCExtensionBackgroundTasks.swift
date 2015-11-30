//
//  WelcomeVCExtensionBackgroundTasks.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/30/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import MapKit

extension WelcomeViewController {
    
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