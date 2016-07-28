//
//  UserController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class UserController {
    
    let songs = [Song?]()
    
    static let sharedController = UserController()
    
    private let cloudKitManager = CloudKitManager()
    
    let fetchRequest = NSFetchRequest(entityName: "User")
    
    var currentUser: User? {
        return users.first
    }
    
    var users: [User] {
        let moc = Stack.sharedStack.managedObjectContext
        do {
            if let users = try moc.executeFetchRequest(fetchRequest) as? [User] {
                print(users)
                return users
            } else {
                return []
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
            return []
        }
    }
    
    func fetchAllUsers(searchTerm: String, completion: ((users: [User]) -> Void)?) {
        cloudKitManager.fetchRecordsWithType("User", recordFetchedBlock: nil) { (records, error) in
            if let records = records {
                let users = records.flatMap({ User(record: $0 )})
                if let completion = completion {
                    let resultsArray = users.filter({$0.matchesSearchTerm(searchTerm)})
                    
                    completion(users: resultsArray)
                }
            }
        }
    }
    
    func createUser(username: String) {
        let user = User(username: username)
        SongController.sharedController.createPlaylist(user, songs: songs) { (playlist) in
            user.playlist = playlist
            self.saveContext()
        }
        
        cloudKitManager.saveRecord(user.cloudKitRecord!) { (record, error) in
            
        }
    }
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Very very sorry, could not save User")
        }
    }
    
    func subscribeToUser(completion: ((success: Bool, error: NSError?) -> Void)?) {
        let predicate = NSPredicate(value: true)
        cloudKitManager.subscribe(User.kType, predicate: predicate, subscriptionID: "User", contentAvailable: true, options: .FiresOnRecordCreation) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func checkSubscriptionToUser(user: User, completion: ((subscribed: Bool) -> Void)?) {
        cloudKitManager.fetchSubscription(user.recordName) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(subscribed: success)
            }
        }
    }
    
    func addSubscriptionToUser(user: User, alertBody: String?, completion: ((success: Bool, error: NSError?) -> Void)?) {
        guard let recordID = user.cloudKitRecordID else {
            fatalError("unable to create cloudKitRereference for subscription") }
        let predicate = NSPredicate(format: "user == %@", argumentArray: [recordID])
        cloudKitManager.subscribe(User.kType, predicate: predicate, subscriptionID: user.recordName, contentAvailable: true, alertBody: alertBody, desiredKeys: nil, options: .FiresOnRecordCreation) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(success:success, error: error)
            }
        }
    }
    
    func removeSubscriptionToUser(user: User, completion: ((success: Bool, error: NSError?) -> Void)?) {
        let subscriptionID = user.recordName
        cloudKitManager.unsubscribe(subscriptionID) { (subscriptionID, error) in
            if let completion = completion {
                let success = subscriptionID != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func toggleUserPostsSubscription(user: User, completion: ((success: Bool, isSubscribed: Bool, error: NSError?) -> Void)?) {
        cloudKitManager.fetchSubscriptions { (subscriptions, error) in
            if subscriptions?.filter({$0.subscriptionID == user.recordName}).first != nil {
                self.removeSubscriptionToUser(user, completion: { (success, error) in
                    if let completion = completion {
                        completion(success: success, isSubscribed: false, error: error)
                    }
                })
                
            } else {
                self.addSubscriptionToUser(user, alertBody: "AAAA!", completion: { (success, error) in
                    if let completion = completion {
                        completion(success: success, isSubscribed: true, error: error)
                    }
                })
            }
        }
    }
}


