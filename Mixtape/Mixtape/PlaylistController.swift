//
//  PlaylistController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreData


class PlaylistController {
    
    static let sharedController =  PlaylistController()
    
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Very very sorry, could not save")
        }
    }
    
    func addSongToPlaylist(song: Song, title: String, playlist: Playlist, completion: ((success: Bool) -> Void)?) {
      _ = Song(title: title)
        saveContext()

        if let completion = completion {
            completion(success: true)
        }

        
        }
        
    

    
}
