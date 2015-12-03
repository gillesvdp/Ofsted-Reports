//
//  Search.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import CoreData


class Search: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var postCode: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var radius: Int
    @NSManaged var textDescription: String
    @NSManaged var schools: [School]?
    
    struct Keys {
        static let date = "date"
        static let postCode = "postCode"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let radius = "radius"
        static let textDescription = "textDescription"
        static let schools = "schools"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(postCode: String?, latitude: Double, longitude: Double, radius: Int, description: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Search", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.date = NSDate()
        
        if let _ = postCode {
            self.postCode = postCode
        }
        
        self.longitude = longitude
        self.latitude = latitude
        self.textDescription = description
        self.radius = radius
    }
}
