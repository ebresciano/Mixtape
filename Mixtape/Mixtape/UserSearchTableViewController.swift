//
//  UserSearchTableViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/12/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit

class UserSearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var searchController: UISearchController?
    var resultsArray: [SearchableRecord] = []
    var users: [User]?
    
    // MARK: - Outlets
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchController()
    }
    
    enum OtherUser {
    case following
    case notFollowing
    }
    
    var otherUser = OtherUser.notFollowing

//    func upDateFollowButton() {
//        if otherUser  == .following {
//            otherUser = .notFollowing
//            followButton.setTitle("Follow", forState: .Normal)
//        } else {
//            otherUser = .following
//                followButton.setTitle("Unfollow", forState: .Normal)
//            }
//       }

    @IBAction func followButtonTapped(sender: AnyObject) {
    }
   
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(resultsArray.count)
        return resultsArray.count
    }

    // MARK: - Search Controller
    
    func setUpSearchController() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.definesPresentationContext = true
        tableView.tableHeaderView = searchController?.searchBar
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if let resultsViewController = searchController.searchResultsController as? UserSearchTableViewController,
            let searchTerm = searchController.searchBar.text?.lowercaseString,
            let users = users {
            
            resultsViewController.resultsArray = users.filter({$0.matchesSearchTerm(searchTerm)})
            resultsViewController.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultsCell", forIndexPath: indexPath)
        if let user = resultsArray[indexPath.row] as? User {
            cell.textLabel?.text = user.username
            
        }
        
        return cell
        
        }

}
