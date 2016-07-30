//
//  PlaylistViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/13/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIToolbarDelegate {
    
    var isPlaying = false
    var timer:NSTimer!
    
    static let sharedController = PlaylistViewController()

    @IBOutlet weak var playlistToolbar: UIToolbar!
    
    var fetchedResultsController: NSFetchedResultsController?
    
    @IBOutlet weak var tableView: UITableView!
    var songs: [Song] {
        return SongController.sharedController.songs
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.blackColor()   
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    

    // MARK: - Actions
    
    @IBAction func skipBackTapped(sender: AnyObject) {
        MusicPlayerController.sharedController.controller.skipToNextItem()
    }
    @IBAction func skipForewardTapped(sender: AnyObject) {
        MusicPlayerController.sharedController.controller.skipToPreviousItem()
    }
    @IBAction func playButtonTapped(sender: AnyObject) {
        MusicPlayerController.sharedController.setQueWithStoreIDs(songs.map {$0.trackID})
        MusicPlayerController.sharedController.controller.play()
//          timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: ("updateTime"), userInfo: nil, repeats: true)
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var playButton: UIBarButtonItem!
    
    @IBOutlet weak var playlistTableView: UITableView!
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as? SongTableViewCell ?? SongTableViewCell()
        let song = songs[indexPath.row]
        cell.updateWithSong(song)
        return cell
    }
}
