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
    let cityContextApiKey = "f49d89dd7d5ca9a30d9cf5fbd3db7680"
    
    // Segues
    let showMap = "showMap"
    let showSchoolDetails = "showSchoolDetails"
    let showSettings = "showSettings"
    
    // VC Text
    /// WelcomeViewController
    let welcomeViewControllerTitle = "Ofsted Reports"
    let errorTitle = "Error"
    let errorOk = "Ok"
    let noPostCodeErrorMessage = "Please type your prefered post code."
    let noUserLocationErrorMessage = "Could not determine your location. Please use another method."
    let noSelectedLocationErrorMessage = "Please choose a location on the map using a long-press over the map."
    let noSchoolsInAreaError = "No schools could be found in this area. Please try again with a larger search radius or in another area."
    
    /// MapViewController
    let mapAnnotationReuseIdentifier = "pin"
    
    /// SchoolDetailTableViewController
    let tableReuseIdentifier = "cell"
    
}