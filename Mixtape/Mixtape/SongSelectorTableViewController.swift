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
    
    var image = UIImage?()
    
    var songs = [Song]()
    
    var loadingIndicator: UIActivityIndicatorView!
    
    var loadingIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.darkGrayColor()

        songSearchBar.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var songSearchBar: UISearchBar!
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songResultsCell", forIndexPath: indexPath) as? SongSearchResultsTableViewCell ?? SongSearchResultsTableViewCell()
        let song = songs[indexPath.row]
        
        SongController.getAlbumArtForSong(song, completion: { (songImage) in
            if let songImage = songImage, imageData = UIImageJPEGRepresentation(songImage, 0.8) {
                song.image = imageData
                cell.updateWithSong(song)
            }
        })
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - SearchBar functions
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        songSearchBar.resignFirstResponder()
    }
    
    func presentLoadingIndicator() {
        loadingIndicatorView = UIView(frame: CGRectMake((self.view.frame.width / 2) - 30, (self.view.frame.height / 2) - 90, 60, 60))
        loadingIndicatorView.layer.cornerRadius = 15
        loadingIndicatorView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
        loadingIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, loadingIndicatorView.frame.width, loadingIndicatorView.frame.height))
        loadingIndicator.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicator.hidesWhenStopped = true
        loadingIndicatorView.addSubview(loadingIndicator)
        self.view.addSubview(loadingIndicatorView)
        loadingIndicator.startAnimating()
    }

    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        presentLoadingIndicator()
        guard let searchTerm = searchBar.text else { return }
        SongController.searchSongsByTitle(searchTerm) { (songs) in
            self.songs = songs
            if songs.count > 0 {
                self.tableView.reloadData()
                self.loadingIndicator.stopAnimating()
                self.loadingIndicatorView.hidden = true
            } else {
                return
            }
        }
    }
    
    func songSelected(cell: SongSearchResultsTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell), user = UserController.sharedController.users.first, playlist = user.playlist {
            let song = songs[indexPath.row]
            SongController.sharedController.postSong(song.artist, title: song.title, playlist: playlist, image: song.image ?? NSData(), trackID: song.trackID) {
                    self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

