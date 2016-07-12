//
//  MusicPlayerController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/12/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation

class MusicPlayerController {

static let sharedInstance =  MusicPlayerController()
    

    static let baseURLString =  (string:"https://itunes.apple.com/lookup?id=\()&entity=song")

static func searchSongsByTitle(title: String, completion: (songs : [Song]) -> Void) {
    
    guard let url = NSURL(string: baseURLString) else {
        completion(songs: [])
        return
    }
    
    let urlParameters = ["term"]
    
    NetworkController.performRequestForURL(url, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
        guard let data = data,
            let jsonDictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String:AnyObject]),
            let songDictionaries = jsonDictionary?["results"] as? [[String: AnyObject]] else {
                
                print("could not serialize json")
                completion(songs: [])
                return
        }
        
        let songs = songDictionaries.flatMap({Song(jsonDictionary:$0)})
        completion(songs: songs)
    }
    
}
    
}
