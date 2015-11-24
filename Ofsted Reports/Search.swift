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

    @NSManaged var date: NSDate?
    @NSManaged var postCode: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var radius: NSNumber?
    @NSManaged var schools: NSOrderedSet?
    
    struct Keys {
        static let date = "date"
        static let postCode = "postCode"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let radius = "radius"
        static let schools = "schools"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(postCode: String?, latitude: Double?, longitude: Double?, radius: Int?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Search", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.date = NSDate()
        
        if let _ = postCode {
            self.postCode = postCode
        }
        
        if let _ = longitude {
            self.longitude = longitude! as NSNumber
        }
        
        if let _ = latitude {
            self.latitude = latitude! as NSNumber
        }
        
        self.radius = radius! as NSNumber
        
        self.schools = []
    }
}
