//
//  ConstantStrings.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation

class ConstantStrings {
    static var sharedInstance = ConstantStrings()
    
    // API Key
    let cityContextApiUrl = "http://api.citycontext.com/beta/"
    let cityContextApiByPostCode = "postcodes/"
    let cityContextApiByCoordinates = "@"
    let cityContextApiSearchRadiusUrl = "&school_search_radius="
    let cityContextApiSearchRadiusValue = 4000 // Min 100, Max 4000 (value in meters)
    let cityContextApiKey = "f49d89dd7d5ca9a30d9cf5fbd3db7680"
    
    // Segues
    let showMap = "showMap"
    let showSchoolDetails = "showSchoolDetails"
    
    // VC Text
    /// WelcomeViewController
    let welcomeViewControllerTitle = "Ofsted Reports"
    let errorTitle = "Error"
    let errorOk = "Ok"
    let noPostCodeErrorMessage = "Please type your prefered post code."
    let noLocationErrorMessage = "Could not determine your location. Please use another method."
    
    /// MapViewController
    let mapAnnotationReuseIdentifier = "pin"
    
    /// SchoolDetailTableViewController
    let tableReuseIdentifier = "cell"
    
}