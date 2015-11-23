//
//  AccessAPI.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation

class AccessAPI {
    
    func get(postCode: String,
        completionHandler: (schoolsInfoArray: [[String: AnyObject]]?, errorString: String?) -> Void ) {
        
        let requestUrl = ConstantStrings.sharedInstance.cityContextApiUrl + postCode + "?user_key=" + ConstantStrings.sharedInstance.cityContextApiKey
            
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
                
                let schoolsInfoArray = parsedResult["schools"] as! [[String : AnyObject]]
                
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(schoolsInfoArray: schoolsInfoArray, errorString: nil)
                
            } catch {
                completionHandler(schoolsInfoArray: nil, errorString: "Error parsing the data")
            }
        }
        task.resume()
    }
}


