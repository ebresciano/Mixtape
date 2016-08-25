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
    var loadingIndicator: UIActivityIndicatorView!
    var loadingIndicatorView: UIView!
    
    
    @IBOutlet weak var userSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.lightGrayColor()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let users = users {
            return users.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userSearchResultsCell", forIndexPath: indexPath) as? UserTableViewCell ?? UserTableViewCell()
        if let user = users?[indexPath.row] {
            cell.updateWithUser(user)
        }
        return cell
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
        UserController.sharedController.fetchAllUsers(searchTerm) { (users) in
            self.users = users
            if users.count > 0 {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicatorView.hidden = true
                })
                
            } else {
                return
            }
        }
    }
}