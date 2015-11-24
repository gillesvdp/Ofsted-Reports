//
//  AccessAPI.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation

class AccessAPI {
    
    func getWithPostCode(postCode: String, radius: Int,
        completionHandler: (schoolsInfoArray: [[String: AnyObject]]?, errorString: String?) -> Void ) {
        
        let requestUrl = ConstantStrings.sharedInstance.cityContextApiUrl + ConstantStrings.sharedInstance.cityContextApiByPostCode + postCode + "?user_key=" + ConstantStrings.sharedInstance.cityContextApiKey + ConstantStrings.sharedInstance.cityContextApiSearchRadiusUrl +  String(radius)
            
        let request = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            guard error == nil else {
                completionHandler(schoolsInfoArray: nil, errorString: "Connection error")
                return
            }
            
            do {
                let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                print(parsedResult)
                
                guard parsedResult["schools"] != nil else {
                    completionHandler(schoolsInfoArray: nil, errorString: "API error")
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
    
    func getWithCoordinates(latitude: Double, longitude: Double, radius: Int,
        completionHandler: (schoolsInfoArray: [[String: AnyObject]]?, errorString: String?) -> Void ) {
            
            let requestUrl = ConstantStrings.sharedInstance.cityContextApiUrl + ConstantStrings.sharedInstance.cityContextApiByCoordinates + String(latitude) + "," + String(longitude) + "?user_key=" + ConstantStrings.sharedInstance.cityContextApiKey + ConstantStrings.sharedInstance.cityContextApiSearchRadiusUrl +  String(radius)
            
            let request = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) {
                data, response, error in
                
                guard error == nil else {
                    completionHandler(schoolsInfoArray: nil, errorString: "Connection error")
                    return
                }
                
                do {
                    let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    print(parsedResult)
                    
                    guard parsedResult["schools"] != nil else {
                        completionHandler(schoolsInfoArray: nil, errorString: "API error")
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


