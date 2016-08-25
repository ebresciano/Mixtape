//
//  Playlist.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class Playlist: SyncableObject, CloudKitManagedObject {
    
    static let kType = "Playlist"
    static let kUser = "User"
    //var followedUsers = [User]()
    
    convenience init(user: User, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName(Playlist.kType, inManagedObjectContext: context) else { fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.user = user
        self.recordName = self.nameForManagedObject()
        self.songs = nil
    }
    
    var currentUser: User? {
        let fetchRequest = NSFetchRequest(entityName: "User")
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [User] ?? []
        return results.first ?? nil
    }

    var recordType: String = Playlist.kType
    
    var cloudKitRecord: CKRecord? {
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        guard let user = user,
            let playlistRecord = user.cloudKitRecord else { fatalError("Unfortunately a User Playlist relationship does not exist") }
        
        record[Playlist.kUser] = CKReference(record: playlistRecord, action: .DeleteSelf)
        return record
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Playlist", inManagedObjectContext: context) else { fatalError("Error: Core Data failed to create entity from entity description.") }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        self.recordName = record.recordID.recordName
    }
    
    func updateWithRecord(record: CKRecord) {
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record)
    }
}
