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


class User: SyncableObject, SearchableRecord, CloudKitManagedObject {
    
    static let kType = "User"
    
    static let kUsername = "username"
    
    private let kUsername = "username"
    
    convenience init(username: String, playlist: Playlist? = nil, song: Song? = nil, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext){
        
        guard let entity = NSEntityDescription.entityForName(User.kType, inManagedObjectContext: context) else { fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.username = username
        self.recordName = NSUUID().UUIDString
    }
    
    convenience init?(dictionary:[String:AnyObject]) {
        self.init()
        guard let username = dictionary[kUsername] as? String else {
            return nil }
        self.username = username
    }
    
    @objc func matchesSearchTerm(searchTerm: String) -> Bool {
        return username.containsString(searchTerm) ?? false
    }
    
    var recordType: String = User.kType
    
    var cloudKitRecord: CKRecord? {
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record[User.kUsername] = username
          
        return record
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let username = record[User.kUsername] as? String
            else {
                return nil
        }
        
        guard let entity = NSEntityDescription.entityForName(User.kType, inManagedObjectContext: context)
            else { fatalError("Error: CoreData failed to create entity from entity description. \(#function)") }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.username = username
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        self.recordName = record.recordID.recordName
        
    }
    
    func updateWithRecord(record: CKRecord) {
        
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record)
    }

    
}






