//
//  UserController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class UserController {
    
    var playlist = Playlist()
    
    var isSyncing: Bool = false
    
    let songs = [Song?]()
    
    private let kUserData = "userData"

    static let sharedController = UserController()
    
    private let cloudKitManager = CloudKitManager()
    
    let fetchRequest = NSFetchRequest(entityName: "User")
    
    var currentUser: User? {
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [User] ?? []
        return results.first ?? nil
    }
    //var followedUsers = [User]()
    
    
    var users: [User] {
        let moc = Stack.sharedStack.managedObjectContext
        do {
            if let users = try moc.executeFetchRequest(fetchRequest) as? [User] {
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
        
        if let userCloudKitRecord = user.cloudKitRecord {
            cloudKitManager.saveRecord(userCloudKitRecord, completion: { (record, error) in
                if let record = record {
                    user.update(record)
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
        
        performFullSync()
    }
    
    // So users have an array of people they follow. If the "Follow" button is tapped on a user, then add that users display name to the current users "Following" array. make main feed the current users, following users songs by time of post.
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Very very sorry, could not save User")
        }
    }
    
    func userWithName(userRecordID: CKRecordID, completion: ((user: User?) -> Void)?) {
        cloudKitManager.fetchRecordWithID(userRecordID) { (record, error) in
            if let record = record,
                let user = User(record: record) {
                if let completion = completion{
                    completion(user: user)
                }
            } else {
                if let completion = completion {
                    completion(user: nil)
                }
            }
        }
    }
    
    func pushChangesToCloudKit(user: User, completion: ((success: Bool, error: NSError?)->Void)?) {
        guard let userRecord = user.cloudKitRecord else { return }
        cloudKitManager.saveRecords([userRecord], perRecordCompletion: nil, completion: nil)
    }
    
    func fetchUserRecords(type: String, completion: ((records:[CKRecord]) -> Void)?) {
        let predicate = NSPredicate(value: true)
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
        }) { (records, error) in
            if error != nil {
                print("Error: Could not retrieve user records\(error?.localizedDescription)")
            }
            if let completion = completion, records = records {
                completion(records: records)
            }
        }
    }
    
    // MARK: - Sync
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
            
            self.fetchNewRecords("User") {
                
                self.isSyncing = false
                
                if let completion = completion {
                    
                    completion()
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
                
            case "Playlist":
                let _ = Playlist(record: record)
                
            default:
                return
            }
            
            self.saveContext()
            
        }) { (records, error) in
            
            if error != nil {
                print("😱 Error fetching records \(error?.localizedDescription)")
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
  //  func addUserToPlaylist(playlist: Playlist, user: User) {
       // followedUsers.append(user)
   // }
    
    //    func removeUserFromPlaylist(playlist: Playlist, user: User) {
    //        let unfollowedUser = followedUsers.filter ({
    //           $0.username == User.username })
    //  }
}


