//
//  ProfileTableViewCell.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/27/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var albumArtImage: UIImageView!

    func updateProfileWithSong(song: Song) {
        songTitleLabel.text = song.title
        artistNameLabel.text = song.artist
        
        if let image = UIImage(data: song.image) {
            albumArtImage.image = image
        }
    }
}