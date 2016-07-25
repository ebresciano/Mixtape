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
    
//    var currentUser: User? {
//        var user: User?
//        cloudKitManager.fetchLoggedInUserRecord { (record, error) in
//            if let error = error {
//                return
//            } else {
//                guard let record = record else {
//                    return
//                }
//                // Retrieve user if the have an account in your app else have them create an account
//                
//                user = User(record: record)
//        
//                
//            }
//        }
//        return user
//    }
    
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
    
    func fetchAllUsers(completion: ((users: [User]) -> Void)?) {
        cloudKitManager.fetchRecordsWithType("User", recordFetchedBlock: nil) { (records, error) in
            if let records = records {
                let users = records.flatMap({ User(record: $0 )})
                if let completion = completion {
                    completion(users: users)
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
}


