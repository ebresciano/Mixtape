//
//  Playlist.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation
import CoreData


class Playlist: NSManagedObject {
    
    static let kType = "Playlist"
    static let kUser = "User"
    
    convenience init(playlist: Playlist, user: User, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName(Playlist.kType, inManagedObjectContext: context) else { fatalError() }
        
          self.init(entity: entity, insertIntoManagedObjectContext: context)
        
      }

}
