//
//  ProfileViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/12/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    //    var fetchedResultsController: NSFetchedResultsController?
    
    // MARK: Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = UserController.sharedController.currentUser {
            usernameLabel.text = currentUser.username
            _ = songs
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    var songs: [Song]? = UserController.sharedController.currentUser?.songs?.allObjects as? [Song]
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as? ProfileTableViewCell ?? ProfileTableViewCell()
        if let song = songs?.reverse()[indexPath.row] {
            cell.updateProfileWithSong(song)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let song = SongController.sharedController.songs[indexPath.row]
            SongController.sharedController.deleteSong(song)
            songs?.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
        }
    }
}



