//
//  AccessAPI.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation

class AccessAPI {
    
    func get(postCode: String?, latitude: Double?, longitude: Double?, radius: Int,
        completionHandler: (schoolsInfoArray: [[String: AnyObject]]?, errorString: String?) -> Void ) {
        
        let requestUrlPart1 = ConstantStrings.sharedInstance.cityContextApiUrl
        var requestUrlPart2 = String()
        if postCode != nil { // Searching by postcode
            requestUrlPart2 = ConstantStrings.sharedInstance.cityContextApiByPostCode + postCode!
            
        } else { // Searching by GPS Coordinates
            requestUrlPart2 = ConstantStrings.sharedInstance.cityContextApiByCoordinates + String(latitude!) + "," + String(longitude!)
        }
        let requestUrlPart3 = "?user_key=" + ConstantStrings.sharedInstance.cityContextApiKey + ConstantStrings.sharedInstance.cityContextApiSearchRadiusUrl +  String(radius)
        let requestUrl = requestUrlPart1 + requestUrlPart2 + requestUrlPart3
        
        let request = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
                
            guard error == nil else {
                completionHandler(schoolsInfoArray: nil, errorString: "Please check your network connection")
                return
            }
                
            do {
                let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                guard let noData = parsedResult["schools"] as? [AnyObject]? where noData != nil else {
                    if let error = parsedResult["error"] as? String? {
                        if error == "user key \(ConstantStrings.sharedInstance.cityContextApiKey) is invalid" {
                            completionHandler(schoolsInfoArray: nil, errorString: "Incorrect API Key, please contact us")
                        } else if error == "Postcode not found" {
                            completionHandler(schoolsInfoArray: nil, errorString: "Incorrect post code, please try with another postcode")
                        }
                    } else {
                        completionHandler(schoolsInfoArray: nil, errorString: "Please contact us") // Other error messages
                    }
                    return
                }
                    
                let schoolsInfoArray = parsedResult["schools"] as! [[String : AnyObject]]
                completionHandler(schoolsInfoArray: schoolsInfoArray, errorString: nil)
                    
            } catch {
                completionHandler(schoolsInfoArray: nil, errorString: "Error parsing the data")
            }
        }
        task.resume()
    }
}


