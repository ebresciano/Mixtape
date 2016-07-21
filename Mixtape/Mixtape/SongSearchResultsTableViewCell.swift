//
//  SongSearchResultsTableViewCell.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/20/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit

class SongSearchResultsTableViewCell: UITableViewCell {
    

    @IBOutlet weak var albumArtImage: UIImageView!
   
    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var songArtistLabel: UILabel!
    
    @IBAction func postSongButtonTapped(sender: AnyObject) {
              
    }
    
    func updateWithSong(song: Song) {
        songTitleLabel.text = song.title
        songArtistLabel.text = song.artist
        albumArtImage.image = UIImage(named: "MixtapeLogo")
        
        ImageController.getAlbumArt(song.artworkURLString ?? "") { (image) in
            self.albumArtImage.image = image
        }
    }
}
