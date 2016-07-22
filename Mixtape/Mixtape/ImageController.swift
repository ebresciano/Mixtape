//
//  ImageController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/20/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation
import UIKit

class ImageController {
    
    static func getAlbumArt(url: String, completion: (image: UIImage?) -> Void) {
        NetworkController.performRequestForURL(url, httpMethod: .Get) { (data, error) in
            if let error = error {
                print("Error fetching image \(error.localizedDescription)")
                completion(image: nil)
            } else {
                guard let data = data else {
                    completion(image: nil)
                    return
                }
                let image = UIImage(data: data)
                dispatch_async(dispatch_get_main_queue(), {
                    completion(image: image)
                })
            }
        }
    }
}