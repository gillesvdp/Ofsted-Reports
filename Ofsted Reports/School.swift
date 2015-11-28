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
    
    @NSManaged var id: NSDate
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
        static let id = "id"
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
    
    init(photoWebUrl: String?, distanceMetres: Int?, lastInspectionDate: String?, lastInspectionUrl: String?, latitude: Double?, leadershipAndManagement: Int?, longitude: Double?, overallEffectiveness: Int?, phase: String?, photoLocalUrl: String?, qualityOfTeaching: Int?, schoolName: String?, typeOfEstablishment: String?, urn: Int?, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("School", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.id = NSDate()
        if let _ = overallEffectiveness     {   self.overallEffectiveness       = overallEffectiveness      }
        if let _ = qualityOfTeaching        {   self.qualityOfTeaching          = qualityOfTeaching         }
        if let _ = leadershipAndManagement  {   self.leadershipAndManagement    = leadershipAndManagement   }
        if let _ = distanceMetres           {   self.distanceMetres             = distanceMetres            }
        if let _ = lastInspectionDate       {   self.lastInspectionDate         = lastInspectionDate        }
        if let _ = lastInspectionUrl        {   self.lastInspectionUrl          = lastInspectionUrl         }
        if let _ = latitude                 {   self.latitude                   = latitude                  }
        if let _ = longitude                {   self.longitude                  = longitude                 }
        if let _ = phase                    {   self.phase                      = phase                     }
        if let _ = schoolName               {   self.schoolName                 = schoolName                }
        if let _ = typeOfEstablishment      {   self.typeOfEstablishment        = typeOfEstablishment       }
        if let _ = urn                      {   self.urn                        = urn                       }
        if let _ = photoLocalUrl            {   self.photoLocalUrl              = photoLocalUrl             }
        if let _ = photoWebUrl              {   self.photoWebUrl                = photoWebUrl               }
    }
    
    
    /// Using SchoolRatings enum to easily access text equivalent of ratings.
    /// When accessing this value, we can use a .Outstanding, .Good, etc instead of their numeric equivalent: .1, .2, .3
    ///
    var overallEffectivenessSchoolRating : SchoolRatings {
        get {
            if let _ = self.overallEffectiveness {
                return SchoolRatings(rawValue: self.overallEffectiveness!)!
            } else {
                return SchoolRatings.Unknown
            }
        }
        set {
            self.overallEffectiveness = newValue.rawValue
        }
    }
    
    var leadershipAndManagementSchoolRating : SchoolRatings {
        get {
            if let _ = self.leadershipAndManagement {
                return SchoolRatings(rawValue: self.leadershipAndManagement!)!
            } else {
                return SchoolRatings.Unknown
            }
        }
        set {
            self.leadershipAndManagement = newValue.rawValue
        }
    }
    
    var qualityOfTeachingSchoolRating : SchoolRatings {
        get {
            if let _ = self.qualityOfTeaching {
                return SchoolRatings(rawValue: self.qualityOfTeaching!)!
            } else {
                return SchoolRatings.Unknown
            }
        }
        set {
            self.leadershipAndManagement = newValue.rawValue
        }
    }
    
    // Function that tells if the school matches the current set of user preferences, returns true or false
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
            if self.overallEffectivenessSchoolRating == .Outstanding {
                funcReturn = false
            }
        }
        
        if filterPrefs[1][1] == "No" {
            if self.overallEffectivenessSchoolRating == .Good {
                funcReturn = false
            }
        }
        if filterPrefs[1][2] == "No" {
            if self.overallEffectivenessSchoolRating == .RequiresImprovement {
                funcReturn = false
            }
        }
        if filterPrefs[1][3] == "No" {
            if self.overallEffectivenessSchoolRating == .Inadequate {
                funcReturn = false
            }
        }
        
        return funcReturn
    }
}
