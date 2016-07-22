//
//  Playlist+CoreDataProperties.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/22/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Playlist {

    @NSManaged var user: User?
    @NSManaged var songs: NSOrderedSet?

}
