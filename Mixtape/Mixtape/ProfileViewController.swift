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
    
    var fetchedResultsController: NSFetchedResultsController?
    
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
    
    
    var songs: [Song]? {
        if let songs = UserController.sharedController.currentUser?.songs?.allObjects as? [Song] {
            print(songs)
            return songs
        } else {
            return nil
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs!.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as? ProfileTableViewCell ?? ProfileTableViewCell()
        
        if let song = songs?[indexPath.row] {
            cell.updateProfileWithSong(song)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
