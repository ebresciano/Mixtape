//
//  User+CoreDataProperties.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/27/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var username: String?
    @NSManaged var playlist: Playlist?
    @NSManaged var users: NSOrderedSet?
    @NSManaged var songs: NSSet?

}
