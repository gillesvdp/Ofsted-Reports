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

// Insert code here to add functionality to your managed object subclass
    
    @NSManaged var date: NSDate?
    @NSManaged var postCode: String?
    @NSManaged var schools: NSOrderedSet?
    
    struct Keys {
        static let date = "date"
        static let postCode = "postCode"
        static let schools = "schools"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(postCode: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Search", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.date = NSDate()
        self.postCode = postCode
        self.schools = []
    }
}
