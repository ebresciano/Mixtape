//
//  SongController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData

class SongController {
    
    static let sharedController = SongController()
    
    let cloudKitManager: CloudKitManager
    
    var isSyncing: Bool = false
    
    var songs: [Song] {
        let request = NSFetchRequest(entityName: "Song")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        let moc = Stack.sharedStack.managedObjectContext
        do {
            let songs = try moc.executeFetchRequest(request) as! [Song]
            return songs
        } catch
            let error as NSError {
                print(error.localizedDescription)
                return []
        }
    }
    
    init() {
        
        self.cloudKitManager = CloudKitManager()
        
        }
    
    static let baseURLString = "https://itunes.apple.com/search"
    
    static func searchSongsByTitle(searchTerm: String, completion: (songs : [Song]) -> Void) {
        
        let urlParameters = ["entity": "musicTrack", "term": searchTerm]
        
        NetworkController.performRequestForURL(baseURLString, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
            guard let data = data,
                let jsonDictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String:AnyObject]),
                let songDictionaries = jsonDictionary?["results"] as? [[String: AnyObject]] else {
                    
                    print("could not serialize json. Come check the NetworkController in Song.swift file")
                    completion(songs: [])
                    return
            }
            
            let songs = songDictionaries.flatMap({Song(dictionary: $0, timestamp: NSDate())})
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(songs: songs)
            })
        }
    }
    
    static func getAlbumArtForSong(song: Song, completion: ((songImage: UIImage?) -> Void)?) {
        guard let artUrlString = song.artworkURLString else {
            if let completion = completion {
                completion(songImage: nil)
            }
            return
        }
        
        ImageController.getAlbumArt(artUrlString) { (image) in
            guard let image = image else {
                if let completion = completion {
                    completion(songImage: nil)
                }
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let completion = completion {
                    completion(songImage: image)
                }
            })
        }
    }
    
    func createPlaylist(user: User, songs: [Song?], completion: ((playlist: Playlist) -> Void)?) {
        let playlist = Playlist(user: user)
        saveContext()
        
        if let completion = completion {
            completion(playlist: playlist)
        }
    }
    
    func postSong(artist: String, title: String, playlist: Playlist, image: NSData, trackID: String, completion: (() -> Void)?) {
        let song = Song(title: title, artist: artist, image: image, trackID: trackID, playlist: playlist)
        saveContext()
        
        if let completion = completion {
            completion()
        }
        
        if let songRecord = song.cloudKitRecord {
            cloudKitManager.saveRecord(songRecord, completion: { (record, error) in
                if let record = record {
                    song.update(record)
                }
            })
        }
    }
    
    func deleteSong(song: Song) {
    song.managedObjectContext?.deleteObject(song)
    saveContext()

        }
  
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Very very sorry, could not save Song. ERROR: \(error)")
        }
    }
    
    // MARK: - Syncing
    
    func syncedRecords(type: String) -> [CloudKitManagedObject] {
        
        let fetchRequest = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData != nil")
        
        fetchRequest.predicate = predicate
        
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [CloudKitManagedObject] ?? []
        
        return results
    }
    
    func unsyncedRecords(type: String) -> [CloudKitManagedObject] {
        
        let fetchRequest = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData == nil")
        
        fetchRequest.predicate = predicate
        
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [CloudKitManagedObject] ?? []
        
        return results
    }
    
    func performFullSync(completion: (() -> Void)? = nil) {
        
        if isSyncing {
            if let completion = completion {
                completion()
            }
            
        } else {
            isSyncing = true
            
            pushChangesToCloudKit { (success) in
                
                self.fetchNewRecords(Song.kType) {
                    
                    self.fetchNewRecords(Playlist.kType, completion: {
                        
                        self.isSyncing = false
                        
                        if let completion = completion {
                            
                            completion()
                        }
                    })
                }
            }
        }
    }
    
    func fetchNewRecords(type: String, completion: (() -> Void)?) {
        
        let referencesToExclude = syncedRecords(type).flatMap({ $0.cloudKitReference })
        var predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
        
        if referencesToExclude.isEmpty {
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            switch type {
                
            case Song.kType:
                let _ = Song(record: record)
                
            case Playlist.kType:
                let _ = Playlist(record: record)
                
            default:
                return
            }
            
            self.saveContext()
            
        }) { (records, error) in
            
            if error != nil {
                print("error: \(error?.localizedDescription)")
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    func pushChangesToCloudKit(completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        let unsavedManagedObjects = unsyncedRecords(Song.kType) + unsyncedRecords(Playlist.kType)
        let unsavedRecords = unsavedManagedObjects.flatMap({ $0.cloudKitRecord })
        
        cloudKitManager.saveRecords(unsavedRecords, perRecordCompletion: { (record, error) in
            
            guard let record = record else { return }
            
            if let matchingRecord = unsavedManagedObjects.filter({ $0.recordName == record.recordID.recordName }).first {
                
                matchingRecord.update(record)
            }
            
        }) { (records, error) in
            
            if let completion = completion {
                
                let success = records != nil
                completion(success: success, error: error)
            }
        }
    }
}