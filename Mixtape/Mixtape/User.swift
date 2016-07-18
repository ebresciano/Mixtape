//
//  User.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation
import CloudKit
import CoreData


class User: SyncableObject, SearchableRecord {
    
    static let kType = "User"
    static let kUsername = "username"
    var users: [User]?
    
    private let kUsername = "username"
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(username: String, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext){
        
        guard let entity = NSEntityDescription.entityForName(User.kType, inManagedObjectContext: context) else { fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.username = username
        
    }
    
    init?(dictionary:[String:AnyObject]) {
        self.init()
        guard let username = dictionary[kUsername] as? String else {
            return nil }
        self.username = username
        
    }
    
    @objc func matchesSearchTerm(searchTerm: String) -> Bool {
        let matchingUserTerms = users?.filter({ $0.matchesSearchTerm(searchTerm) })
        return matchingUserTerms?.count > 0
        
    }

    
   
}






