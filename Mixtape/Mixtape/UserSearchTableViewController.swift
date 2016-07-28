//
//  UserSearchTableViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/12/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData

class UserSearchTableViewController: UITableViewController {
    
    var searchController: UISearchController?
    var users: [User]?
    
    @IBOutlet weak var userSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(users?.count)
        if let users = users {
            return users.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userSearchResultsCell", forIndexPath: indexPath) as? UserTableViewCell ?? UserTableViewCell()
        if let user = users?[indexPath.row] {
            cell.updateWithUser(user)
        }
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        UserController.sharedController.fetchAllUsers(searchTerm) { (users) in
            self.users = users
            print(users.count)
            if users.count > 0 {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
                
            } else {
                return
            }
        }
    }
}