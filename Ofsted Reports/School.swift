//
//  Schools.swift
//  Ofsted Reports
//
//  Created by Gilles on 11/23/15.
//  Copyright © 2015 gillesvdp. All rights reserved.
//

import Foundation
import CoreData


class School: NSManagedObject {
    
    @NSManaged var distanceMetres: NSNumber?
    @NSManaged var lastInspectionDate: String?
    @NSManaged var lastInspectionUrl: String?
    @NSManaged var leadershipAndManagement: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var overallEffectiveness: NSNumber?
    @NSManaged var phase: String?
    @NSManaged var qualityOfTeaching: NSNumber?
    @NSManaged var schoolName: String?
    @NSManaged var typeOfEstablishment: String?
    @NSManaged var urn: NSNumber?
    @NSManaged var photoLocalUrl: String?
    @NSManaged var photoWebUrl: String?
    @NSManaged var search: Search?
    
    struct Keys {
        static let distanceMetres = "distanceMetres"
        static let lastInspectionDate = "lastInspectionDate"
        static let lastInspectionUrl = "lastInspectionUrl"
        static let leadershipAndManagement = "leadershipAndManagement"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let overallEffectiveness = "overallEffectiveness"
        static let phase = "phase"
        static let qualityOfTeaching = "qualityOfTeaching"
        static let schoolName = "schoolName"
        static let typeOfEstablishment = "typeOfEstablishment"
        static let urn = "urn"
        static let photoLocalUrl = "photoLocalUrl"
        static let photoWebUrl = "photoWebUrl"
        static let search = "search"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(photoWebUrl: String, distanceMetres: Int, lastInspectionDate: String, lastInspectionUrl: String, latitude: Double, leadershipAndManagement: Int, longitude: Double, overallEffectiveness: Int, phase: String, photoLocalUrl: String, qualityOfTeaching: Int, schoolName: String, typeOfEstablishment: String, urn: Int, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("School", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.distanceMetres = distanceMetres
        self.lastInspectionDate = lastInspectionDate
        self.lastInspectionUrl = lastInspectionUrl
        self.leadershipAndManagement = leadershipAndManagement
        self.latitude = latitude
        self.longitude = longitude
        self.overallEffectiveness = overallEffectiveness
        self.phase = phase
        self.qualityOfTeaching = qualityOfTeaching
        self.schoolName = schoolName
        self.typeOfEstablishment = typeOfEstablishment
        self.urn = urn
        self.photoLocalUrl = photoLocalUrl
        self.photoWebUrl = photoWebUrl
    }
    
    func matchesUserPreferences() -> Bool {
        var funcReturn = true
        let filterPrefs = NSUserDefaults.standardUserDefaults().valueForKey("filterPrefs") as! [[String]]
        
        // Filtering school as per the filter preferences
        if filterPrefs[0][0] == "No" {
            if self.phase == "Secondary" {
                funcReturn = false
            }
        }
        
        if filterPrefs[0][1] == "No" {
            if self.phase == "Primary" {
                funcReturn = false
            }
        }
        if filterPrefs[0][2] == "No" {
            if self.phase != "Secondary" && self.phase != "Primary" {
                funcReturn = false
            }
        }
        if filterPrefs[1][0] == "No" {
            if self.overallEffectiveness == 1 {
                funcReturn = false
            }
        }
        if filterPrefs[1][1] == "No" {
            if self.overallEffectiveness == 2 {
                funcReturn = false
            }
        }
        if filterPrefs[1][2] == "No" {
            if self.overallEffectiveness == 3 {
                funcReturn = false
            }
        }
        if filterPrefs[1][3] == "No" {
            if self.overallEffectiveness == 4 {
                funcReturn = false
            }
        }
        
        return funcReturn
    }
}
