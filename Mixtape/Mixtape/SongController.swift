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
    
    let cloudKitManager: CloudKitManager
    
    var songs = [Song]()
    
    init() {
        
        self.cloudKitManager = CloudKitManager()
        
        subscribeToNewSongPosts { (success, error) in
            if success {
                print("successfully subscribed")
            }
        }
    }
    
    static let baseURLString = "https://itunes.apple.com/search"
    
    static func searchSongsByTitle(searchTerm: String, completion: (songs : [Song]) -> Void) {
        
        let urlParameters = ["entity": "musicTrack", "term": searchTerm]
        
        NetworkController.performRequestForURL(baseURLString, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
            guard let data = data,
                let jsonDictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String:AnyObject]),
                let songDictionaries = jsonDictionary?["results"] as? [[String: AnyObject]] else {
                    
                    print("could not serialize json")
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
    
    
    func postSong(artist: String, title: String, user: User, image: UIImage, trackID: String, completion: (() -> Void)?) {
        guard let data = UIImageJPEGRepresentation(image, 0.8) else {
            if let completion = completion {
                completion()
            }
            return
        }
        let song = Song(title: title, artist: artist, image: data, trackID: trackID, user: user)
        saveContext()
        
        if let songRecord = song.cloudKitRecord {
            cloudKitManager.saveRecord(songRecord, completion: { (record, error) in
                if let record = record {
                    song.update(record)
                    self.addSubscriptionToSongPost(song, alertBody: "", completion: { (success, error) in
                        if let error = error {
                            print("could not follow: \(error.localizedDescription)")
                        }
                    })
                }
            })
        }
    }
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Very very sorry, could not save")
        }
    }
    
    
    // MARK: - Subscriptions
    
    func subscribeToNewSongPosts(completion: ((success: Bool, error: NSError?) -> Void)?) {
        let predicate = NSPredicate(value: true)
        cloudKitManager.subscribe(Song.kType, predicate: predicate, subscriptionID: "allSongs", contentAvailable: true, options: .FiresOnRecordCreation) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func checkSubscriptionToSongPost(song: Song, completion: ((subscribed: Bool) -> Void)?) {
        cloudKitManager.fetchSubscription(song.recordName) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(subscribed: success)
            }
        }
    }
    
    func addSubscriptionToSongPost(song: Song, alertBody: String?, completion: ((success: Bool, error: NSError?) -> Void)?) {
        guard let recordID = song.cloudKitRecordID else {
            fatalError("unable to create cloudKitRereference for subscription") }
        let predicate = NSPredicate(format: "song == %@", argumentArray: [recordID])
        cloudKitManager.subscribe(Song.kType, predicate: predicate, subscriptionID: song.recordName, contentAvailable: true, alertBody: alertBody, desiredKeys: [Song.kType], options: .FiresOnRecordCreation) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(success:success, error: error)
            }
        }
    }
    
    func removeSubscriptionToSongPosts(song: Song, completion: ((success: Bool, error: NSError?) -> Void)?) {
        let subscriptionID = song.recordName
        cloudKitManager.unsubscribe(subscriptionID) { (subscriptionID, error) in
            if let completion = completion {
                let success = subscriptionID != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func toggleSongPostsSubscription(song: Song, completion: ((success: Bool, isSubscribed: Bool, error: NSError?) -> Void)?) {
        cloudKitManager.fetchSubscriptions { (subscriptions, error) in
            if subscriptions?.filter({$0.subscriptionID == song.recordName}).first != nil {
                self.removeSubscriptionToSongPosts(song, completion: { (success, error) in
                    if let completion = completion {
                        completion(success: success, isSubscribed: false, error: error)
                    }
                })
                
            } else {
                self.addSubscriptionToSongPost(song, alertBody: "Someone you follow posted a song!", completion: { (success, error) in
                    if let completion = completion {
                        completion(success: success, isSubscribed: true, error: error)
                    }
                })
            }
        }
    }
    
}