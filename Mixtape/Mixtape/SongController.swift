//
//  SongController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation

class SongController {
    

    static let baseURL = (string:"https://itunes.apple.com/search")
    
    static func searchSongsByTitle(searchTerm: String, completion: (songs : [Song]) -> Void) {
        
        let url = NSURL(string: baseURL)
        // TODO: Handle spaces in search term
        let urlParameters = ["term": searchTerm]
        
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
}