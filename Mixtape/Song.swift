//
//  Song.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


class Song: SyncableObject, CloudKitManagedObject {
    
    static let kType = "Song"
    static let kTimestamp = "timestamp"
    static let kImage = "image"
    static let kTitle = "title"
    static let kArtist = "artist"
    static let kTrackID = "trackID"
    static let kUser = "user"
    
    convenience init(song: Song, title: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName(Song.kType, inManagedObjectContext: context) else { fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.timestamp = timestamp
        self.title = title
        self.recordName = self.nameForManagedObject()
    }
    
    var recordType: String = Song.kType
    
    var cloudKitRecord: CKRecord? {
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record[Song.kTimestamp] = timestamp
        record[Song.kTitle] = title
        record[Song.kArtist] = artist
        return record
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let timestamp = record.creationDate,
            _ = record[Song.kArtist] as? CKReference,
            _ = record[Song.kTitle] as? CKReference else {
                return nil
        }
        
        guard let entity = NSEntityDescription.entityForName(Song.kType, inManagedObjectContext: context)
            else { fatalError("Error: CoreData failed to create entity from entity description. \(#function)") }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.timestamp = timestamp
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        self.recordName = record.recordID.recordName
        
    }

    
    
}
