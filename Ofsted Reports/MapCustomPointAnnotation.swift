//
//  MapCustomPointAnnotation.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/28/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import UIKit
import MapKit

class MapCustomPointAnnotation: MKPointAnnotation {
    
    // Adding a school variable of type School allows easy referencing to the school associated with each pin
    var school : School?
    
}
