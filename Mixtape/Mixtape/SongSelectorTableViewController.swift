//
//  SongSelectorTableViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/12/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData

class SongSelectorTableViewController: UITableViewController, SongSearchDelegate {
    
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songSearchBar.becomeFirstResponder()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
                cell.updateWithSong(song)
            }
        })
        cell.delegate = self
        
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
    
    func songSelected(cell: SongSearchResultsTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell), user = UserController.sharedController.currentUser {
            let song = songs[indexPath.row]
            SongController.sharedController.postSong(song.artist, title: song.title, user: user, image: song.image ?? NSData(), trackID: song.trackID) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    
}

