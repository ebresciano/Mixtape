//
//  SongController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation

class SongController {
    
    let cloudKitManager: CloudKitManager
    
    var songs = [Song]()
    
    static let baseURL = (string:"https://itunes.apple.com/search")
    
    static func searchSongsByTitle(searchTerm: String, completion: (songs : [Song]) -> Void) {
        
        let url = NSURL(string: baseURL)
        // TODO: Handle spaces in search term
        let urlParameters = ["entity": "musicTrack", "term": searchTerm]
        
        guard let unwrappedURL = url else {
            completion(songs: [])
            return
        }
        
        NetworkController.performRequestForURL(unwrappedURL, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
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
    
    init() {
        
        self.cloudKitManager = CloudKitManager()
        
        subscribeToNewSongPosts { (success, error) in
            if success {
                print("successfully subscribed to new post")
            }
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