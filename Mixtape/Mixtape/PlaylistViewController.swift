//
//  PlaylistViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/13/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController?
    
    let songs = [Song]?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        }
    
    @IBOutlet weak var playlistTableView: UITableView!
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCellWithIdentifier("songCell", forIndexPath: indexPath) as? SongTableViewCell,
        let song = songs?[indexPath.row] else {
            return UITableViewCell() }
        
        cell.updateWithSong(song)
        return cell
    }
}
