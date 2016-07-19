//
//  Song+CoreDataProperties.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/13/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Song {

    @NSManaged var artist: String
    @NSManaged var image: NSData?
    @NSManaged var timestamp: NSDate
    @NSManaged var title: String
    @NSManaged var trackID: String
    @NSManaged var user: User?

}
