//
//  ProfileViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/12/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    // MARK: - Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Actions 
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let songs = [Song]()
        return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath)

        return cell
    }
    
    
}
