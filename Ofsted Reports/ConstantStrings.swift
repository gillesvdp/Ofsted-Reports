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
    let cityContextApiUrl = "http://api.citycontext.com/beta/postcodes/"
    let cityContextApiKey = "f49d89dd7d5ca9a30d9cf5fbd3db7680"
    
    // Segues
    let showMap = "showMap"
    let schowSchoolDetails = "showSchoolDetails"
    
    // VC Text
    /// WelcomeViewController
    let welcomeViewControllerTitle = "Ofsted Reports"
    let errorTitle = "Error"
    let errorOk = "Ok"
    let noPostCodeErrorMessage = "Please type your prefered post code."
    
    /// MapViewController
    
    /// SchoolDetailViewController
    let reuseIdentifier = "cell"
    
}