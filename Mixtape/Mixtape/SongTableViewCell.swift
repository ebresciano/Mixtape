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

    @IBOutlet weak var albumArt: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var trackNameLabel: UILabel!
   
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func updateWithSong(song: Song) {
        trackNameLabel.text = song.title
        artistNameLabel.text = song.artist
        albumArt.image = UIImage()
        
        ImageController.getAlbumArt(song.artworkURLString ?? "") { (image) in
            self.albumArt.image = image

        }
    }


}
