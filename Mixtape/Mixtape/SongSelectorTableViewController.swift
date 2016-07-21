//
//  SongSelectorTableViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/12/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData

class SongSelectorTableViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var image = UIImage?()
    
    var songs = [Song]()
    
    @IBOutlet weak var songSearchBar: UISearchBar!
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songResultsCell", forIndexPath: indexPath) as? SongSearchResultsTableViewCell ?? SongSearchResultsTableViewCell()
        let song = songs[indexPath.row]
        
        SongController.getAlbumArtForSong(song, completion: { (songImage) in
            if songImage != nil {
                print("There is artwork for this song")
                cell.updateWithSong(song)
            }
        })
        
//        cell.textLabel?.text = song.title
//        cell.detailTextLabel?.text = song.artist
        
        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        songSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        SongController.searchSongsByTitle(searchTerm) { (songs) in
            self.songs = songs
            print(songs.count)
            if songs.count > 0 {
                self.tableView.reloadData()
            } else {
                return
            }
        }
    }
    
    // MARK: - Navigation
    
    //     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "songSelectorToPlaylist" {
    //            if let  pvc = segue.destinationViewController as? PlaylistViewController,
    //                let indexPath = self.tableView.indexPathForSelectedRow,
    //            let song = fetchedResultsController?.objectAtIndexPath(indexPath) as? Song {
    //
    //            }
    //        }
    //    
    //    }
    
}
