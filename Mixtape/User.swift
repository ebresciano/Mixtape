//
//  User.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation
import CloudKit
import CoreData


class User: Equatable {
    
    private let kUsername = "username"
   
    
    var dictionaryCopy: [String:AnyObject] {
        return [kUsername: username]
    }
    
    
    init(username: String, password: String) {
        self.username = username
        
        
    }
    
    init?(dictionary:[String:AnyObject]) {
        guard let username = dictionary[kUsername] as? String else {
                return nil }
        self.username = username
            }
    
    
}

func == (lhs: User, rhs: User) -> Bool {
    return lhs.username == rhs.username
}

    



