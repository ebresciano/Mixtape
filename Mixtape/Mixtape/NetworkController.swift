//
//  NetworkController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation

class NetworkController {
    
    enum HTTPMethod: String {
        case Get = "GET"
        case Put = "PUT"
        case Post = "POST"
        case Patch = "PATCH"
        case Delete = "DELETE"
    }
    
    static func performRequestForURL(urlString: String, httpMethod: HTTPMethod, urlParameters: [String: String]? = nil, body: NSData? = nil, completion: ((data: NSData?, error: NSError?) -> Void)? ) {
        
        guard let requestURL = urlFromURLParameters(urlString, urlParameters: urlParameters) else { completion!(data: nil, error: nil); return }
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = httpMethod.rawValue
        request.HTTPBody = body
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
            if let completion = completion {
                completion(data: data, error: error)
            }
        }
        
        dataTask.resume()
    }
    
    static func urlFromURLParameters(urlString: String, urlParameters: [String: String]?) -> NSURL? {
       
        if let components = NSURLComponents(string: urlString) {
            components.queryItems = urlParameters?.flatMap({NSURLQueryItem(name: $0.0, value: $0.1)})
            
            if let url = components.URL {
                return url
            } else {
                fatalError("URL optional is nil")
            }
        } else {
            print("Something went wrong when creating components")
            return nil
        }
    }
}
