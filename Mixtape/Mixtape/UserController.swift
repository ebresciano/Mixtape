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
    
    static let sharedController = UserController()
    
    let fetchRequest = NSFetchRequest(entityName: "User")
    
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
        _ = User(username: username)
        saveContext()
    }
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Very very sorry, could not save")
        }
    }
}


