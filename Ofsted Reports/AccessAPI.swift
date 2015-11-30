//
//  AccessAPI.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation

class AccessAPI {
    
    func getLocationForPostCode(postCode: String,
        completionHandler: (latitude: Double?, longitude: Double?, errorString: String?) -> Void) {
            
        let requestUrl = "http://uk-postcodes.com/postcode/\(postCode).json"
        let request = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            guard error == nil else {
                return
            }
            
            do {
                let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                // If the api returns errors
                guard let noData = parsedResult["geo"] as? [String: AnyObject]? where noData != nil else {
                    if let error = parsedResult["code"] as? Int {
                        if error == 404 {
                            completionHandler(latitude: nil, longitude: nil, errorString: ConstantStrings.sharedInstance.unknownPostCodeError)
                        }
                    } else {
                        completionHandler(latitude: nil, longitude: nil, errorString: ConstantStrings.sharedInstance.otherError)
                    }
                    return
                }
                // Use SiftyJSON to check this
                let latitude = parsedResult["geo"]!!["lat"] as! Double
                let longitude = parsedResult["geo"]!!["lng"] as! Double
                completionHandler(latitude: latitude, longitude: longitude, errorString: nil)
                
            } catch {
                completionHandler(latitude: nil, longitude: nil, errorString: ConstantStrings.sharedInstance.parsingError)
            }
        }
        task.resume()
    }
    
    func getSchoolsNearLocation(latitude: Double?, longitude: Double?, radius: Int,
        completionHandler: (schoolsInfoArray: [[String: AnyObject]]?, errorString: String?) -> Void ) {
        
        let requestUrlPart1 = ConstantStrings.sharedInstance.cityContextApiUrl
        let requestUrlPart2 = ConstantStrings.sharedInstance.cityContextApiByCoordinates + String(latitude!) + "," + String(longitude!)
        let requestUrlPart3 = "?user_key=" + ConstantStrings.sharedInstance.cityContextApiKey + ConstantStrings.sharedInstance.cityContextApiSearchRadiusUrl +  String(radius)
        let requestUrl = requestUrlPart1 + requestUrlPart2 + requestUrlPart3
        
        let request = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // If there is an network connection error
            guard error == nil else {
                completionHandler(schoolsInfoArray: nil, errorString: ConstantStrings.sharedInstance.networkError)
                return
            }
                
            do {
                let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                // If the api returns errors
                guard let noData = parsedResult["schools"] as? [AnyObject]? where noData != nil else {
                    if let error = parsedResult["error"] as? String {
                        if error == "user key \"\(ConstantStrings.sharedInstance.cityContextApiKey)\" is invalid" {
                            completionHandler(schoolsInfoArray: nil, errorString: ConstantStrings.sharedInstance.apiKeyError)
                        }
                    } else {
                        completionHandler(schoolsInfoArray: nil, errorString: ConstantStrings.sharedInstance.otherError)
                    }
                    return
                }
                let schoolsInfoArray = parsedResult["schools"] as! [[String : AnyObject]]
                completionHandler(schoolsInfoArray: schoolsInfoArray, errorString: nil)
                    
            } catch {
                completionHandler(schoolsInfoArray: nil, errorString: ConstantStrings.sharedInstance.parsingError)
            }
        }
        task.resume()
    }
}


