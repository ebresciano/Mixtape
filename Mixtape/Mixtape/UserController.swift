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
    
    private let allUsersKey = "allUsers"
    
    var users: [User] {
        var newList = [User]()
        if let userList = NSUserDefaults.standardUserDefaults().arrayForKey(allUsersKey) as? [[String: AnyObject]] {
            for dict in userList {
                if let user = User(username: username) {
                    newList.append(user)
                }
            }
            return newList
        }
        
        return []
    }
    
    var currentUser: User?
    
    static let sharedController = UserController()
    
    private let userDataKey = "userData"
    
    init() {
        
        guard let _ = NSUserDefaults.standardUserDefaults().arrayForKey(allUsersKey) as? [[String: AnyObject]] else {
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: allUsersKey)
            return
        }
        
    }
    
    func createUser(username: String) {
        var oldUsersList = NSUserDefaults.standardUserDefaults().arrayForKey(allUsersKey) as? [[String: AnyObject]] ?? [[String: AnyObject]]()
        let newUser = User(username: username)
        let newUserDictionary = newUser.dictionaryCopy
        oldUsersList.append(newUserDictionary)
        NSUserDefaults.standardUserDefaults().setObject(oldUsersList, forKey: allUsersKey)
    }
}



