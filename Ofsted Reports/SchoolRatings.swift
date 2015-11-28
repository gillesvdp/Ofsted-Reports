//
//  SchoolRatings.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/28/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation

enum SchoolRatings : NSNumber {
    case Outstanding                = 1
    case Good                       = 2
    case RequiresImprovement        = 3
    case Inadequate                 = 4
    case Unknown                    = 999 // See variables based on this enum in the School class
    
    var text: String? {
        switch self {
        case Outstanding:           return "Outstanding"
        case Good:                  return "Good"
        case RequiresImprovement:   return "Requires Improvement"
        case Inadequate:            return "Inadequate"
        case Unknown:               return "Unknown"
        }
    }
}
