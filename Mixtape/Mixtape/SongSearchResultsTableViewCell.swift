//
//  SongSearchResultsTableViewCell.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/20/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class SongSearchResultsTableViewCell: UITableViewCell {
    
    var delegate: SongSearchDelegate?
    
    var trackID = String()
    
   // MARK: - Outlets
    
    @IBOutlet weak var albumArtImage: UIImageView!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var songArtistLabel: UILabel!
    
    // MARK: - Actions 
    
    @IBAction func postSongButtonTapped(sender: AnyObject) {
        delegate?.songSelected(self)
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

protocol SongSearchDelegate: class {
    func songSelected(cell: SongSearchResultsTableViewCell)
    
}
