//
//  SongTableViewCell.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/12/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    // MARK: - Outlets
    
    @IBOutlet weak var albumArt: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var timePlayedLabel: UILabel!
   
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var trackNameLabel: UILabel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//    func updateTime() {
//        var currentTime = Int()
//        var minutes = currentTime/60
//        var seconds = currentTime - minutes * 60
//        
//        timePlayedLabel.text = NSString(format: "%02d:%02d", minutes,seconds) as String
//    }
   
    func updateWithSong(song: Song) {
        trackNameLabel.text = song.title
        artistNameLabel.text = song.artist
        albumArt.image = UIImage()
        usernameLabel.text = UserController.sharedController.currentUser?.username
        if let image = UIImage(data: song.image) {
            albumArt.image = image
        }
    }
}
