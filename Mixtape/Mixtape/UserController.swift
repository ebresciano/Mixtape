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
    
    let fetchRequest = NSFetchRequest(entityName: "User")
    
    var currentUser: User? {
        return User(username: "")
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
    
    func createUser(username: String) {
        // TODO: Call create playlist to be able to add a playlist to this user being created
        let user = User(username: username)
        let playlist = Playlist(user: user)
        SongController.sharedController.createPlaylist(user, songs: songs) { (playlist) in
            
        }

        saveContext()
    }
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Very very sorry, could not save User")
        }
    }
}


