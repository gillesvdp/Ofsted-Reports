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
            
            // There was no error with the request
            guard error == nil else {
                completionHandler(latitude: nil, longitude: nil, errorString: String(error))
                return
            }
            
            // Got a successful 2XX response from the server
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                var errorString : String
                // 404 error means Unknown postcode error
                if (response as? NSHTTPURLResponse)?.statusCode == 404 {
                    errorString = ConstantStrings.sharedInstance.unknownPostCodeError
                
                // Handle other errors
                } else if let response = response as? NSHTTPURLResponse {
                    errorString = "Your request returned an invalid response! Status code: \(response.statusCode)!"
                } else if let response = response {
                    errorString = "Your request returned an invalid response! Response: \(response)!"
                } else {
                    errorString = "Your request returned an invalid response!"
                }
                completionHandler(latitude: nil, longitude: nil, errorString: errorString)
                return
            }
            
            // The data is not nil
            guard let _ = data else {
                completionHandler(latitude: nil, longitude: nil, errorString: ConstantStrings.sharedInstance.otherError)
                return
            }

            // Let's the parse the data
            do {
                let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                // There is "geo" key in the dictionary
                guard let geoData = parsedResult["geo"] as? [String: AnyObject] else {
                    completionHandler(latitude: nil, longitude: nil, errorString: ConstantStrings.sharedInstance.otherError)
                    return
                }
                
                // There are "lat" and "lng" keys in the dictionary
                guard let latitude = geoData["lat"] as? Double,
                      let longitude = geoData["lng"] as? Double else {
                        
                    completionHandler(latitude: nil, longitude: nil, errorString: ConstantStrings.sharedInstance.parsingError)
                    
                        return
                }
                
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


