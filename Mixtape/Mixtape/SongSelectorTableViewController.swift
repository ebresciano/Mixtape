//
//  SongSelectorTableViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/12/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit

class SongSelectorTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var songs = [Song]()
    
    @IBOutlet weak var songSearchBar: UISearchBar!
    
    @IBOutlet weak var albumArtView: UIImageView!
    
    @IBOutlet weak var artistNameTextField: UILabel!
    
    @IBOutlet weak var trackNameTextField: UILabel!
    
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songResultsCell", forIndexPath: indexPath)
//        _ = songs[indexPath.row]
        
        // Configure the cell...
        
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        SongController.searchSongsByTitle(searchTerm) { (songs) in
            self.songs = songs
            print(songs.count)
            //self.albumArtView.image = Song.kImage
            self.artistNameTextField.text = Song.kArtist
            self.trackNameTextField.text = Song.kTitle
//            dispatch_async(dispatch_get_main_queue(),{
                if songs.count > 0 {
                    self.tableView.reloadData()
                } else {
                    return
                }
//            })
        }
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
