//
//  MusicPlayerController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/28/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

class MusicPlayerController {
    
    static let sharedController = MusicPlayerController()
    
    static let cloudService = SKCloudServiceController()
    
    let controller = MPMusicPlayerController()
    
    static func requestStoreKitPermission(completion: (success: Bool) -> Void) {
        SKCloudServiceController.requestAuthorization { (authorizationStatus) in
            if authorizationStatus == SKCloudServiceAuthorizationStatus.Authorized {
                completion(success: true)
            } else {
                completion(success: false)
            }
        }
    }
    
    // MARK: - MPMusicPlayerController functions
    
    func setQueWithStoreIDs(trackID: [String]) {
        controller.setQueueWithStoreIDs(trackID)
    }
    
    func play(trackID: String) {
        controller.play()
    }
    
    func pause(trackID: String) {
        controller.pause()
    }
    
    func skip(trackID: String) {
        controller.skipToNextItem()
    }
    
    func back(trackID: String) {
        controller.skipToPreviousItem()
    }
    
}
