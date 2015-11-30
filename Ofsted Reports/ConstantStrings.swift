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
    
    // Global
    let tableReuseIdentifier = "cell"
    
    // AccessApi
    let cityContextApiUrl = "http://api.citycontext.com/beta/"
    let cityContextApiByPostCode = "postcodes/"
    let cityContextApiByCoordinates = "@"
    let cityContextApiSearchRadiusUrl = "&school_search_radius="
    let cityContextApiKey = "f49d89dd7d5ca9a30d9cf5fbd3db7680"
    let networkError = "Please check your network connection"
    let apiKeyError = "Incorrect API Key, please contact us"
    let unknownPostCodeError = "Unknown post code, please try with another postcode"
    let otherError = "Error, Please contact us"
    let parsingError = "Error while parsing the data, please contact us"
    
    // Segues
    let showMap = "showMap"
    let showSchoolDetails = "showSchoolDetails"
    let showSettings = "showSettings"
    
    // VC Text
    /// WelcomeViewController
    let welcomeViewControllerTitle = "Ofsted Reports"
    let errorTitle = "Error"
    let errorOk = "Ok"
    
    let noPostCodeErrorTitle = "Missing Post Code"
    let noPostCodeErrorMessage = "Please type your prefered post code to proceed."
    
    let noUserLocationErrorTitle = "Location error"
    let noUserLocationErrorMessage = "We could not determine your location. Please use another method."
    
    let noLocationForPostCodeMessage = "This post code could not be located. Please try again with another postcode."
    
    let noSelectedLocationErrorTitle = "Missing location"
    let noSelectedLocationErrorMessage = "Please choose a location on the map using a long-press over the map."
    
    let noSchoolsInAreaErrorTitle = "No schools in this area"
    let noSchoolsInAreaErrorMessage = "Please try again with a larger search radius or in another area. Note we only cover England at the moment."
    
    /// MapViewController
    let mapAnnotationReuseIdentifier = "pin"
    let noSchoolsMatchCurrentPrefsWarningTitle = "User Preferences"
    let noSchoolsMatchCurrentPrefsWarningMessage = "There are schools in the location and search radius selected, but no schools match the current set of filters. Please adapt your filters to see schools in this area."
    let noSearchGivenToMapViewControllerErrorTitle = "Error"
    let noSearchGivenToMapViewControllerErrorMessage = "Please try again with another search, or contact us if the problem persists"
    
    /// SettingsTableViewController
    let noSearchGivenToSettingTableViewControllerErrorTitle = "Error"
    let noSearchGivenToSettingTableViewControllerErrorMessage = "Please try again with another search, or contact us if the problem persists"
    
    /// SchoolDetailTableViewController
    let noSearchGivenToSchoolDetailTableViewControllerErrorTitle = "Error"
    let noSearchGivenToSchoolDetailTableViewControllerErrorMessage = "Please try again with another search, or contact us if the problem persists"
}