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
    
    var artworkURLString: String?
    var searchArtist: String?
    var searchTitle: String?
    var searchTrackId: String?
    
    static let kTrackName = "trackName"
    static let kArtistName = "artistName"
    static let kTrackID = "trackId"
    static let kArtwork = "artworkUrl100"
        
    static let kType = "Song"
    static let kTimestamp = "timestamp"
    static let kImage = "image"
    static let kTitle = "title"
    static let kArtist = "artist"
    static let kTrack = "trackID"
    static let kUser = "user"
    
    
    // Songs that are initialized from this init get added to the MOC that saves to the persistent store
    convenience init(title: String, artist: String, image: NSData, trackID: String, user: User, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName(Song.kType, inManagedObjectContext: context) else { fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.title = title
        self.artist = artist
        self.image = image
        self.trackID = trackID
        self.timestamp = timestamp
        self.recordName = self.nameForManagedObject()
        self.user = user 
    }
    
    // Songs that are initialized from this init get added to our scratch pad and DO NOT get saved to the persistent store
    convenience init?(dictionary: [String: AnyObject], timestamp: NSDate = NSDate(), scratchPadContext: NSManagedObjectContext = Stack.sharedStack.scratchPadMOC) {
        
        guard let imageString = dictionary[Song.kArtwork] as? String,
            title = dictionary[Song.kTrackName] as? String,
            artist = dictionary[Song.kArtistName] as? String,
            trackID = dictionary[Song.kTrackID] as? Int else {
                return nil
        }
        
        guard let entity = NSEntityDescription.entityForName(Song.kType, inManagedObjectContext: scratchPadContext) else { fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: scratchPadContext)
        self.timestamp = timestamp
        self.title = title
        self.artworkURLString = imageString
        self.artist = artist
        self.trackID = "\(trackID)"
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
            let artist = record[Song.kArtist] as? String,
            let title = record[Song.kTitle] as? String else {
                return nil
        }
        
        guard let entity = NSEntityDescription.entityForName(Song.kType, inManagedObjectContext: context)
            else { fatalError("Error: CoreData failed to create entity from entity description. \(#function)") }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.title = title
        self.artist = artist
        self.timestamp = timestamp
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        self.recordName = record.recordID.recordName
        
    }
    
    func updateWithRecord(record: CKRecord) {
        
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record)
    }
    
    
    
    
    
}
