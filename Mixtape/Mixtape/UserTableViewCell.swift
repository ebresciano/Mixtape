//
//  UserTableViewCell.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/25/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit
import CoreData

class UserTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var user: User?
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    enum OtherUser {
        case following
        case notFollowing
    }
    
    var otherUser = OtherUser.notFollowing
    
    func updateFollowButton() {
        
        guard let user = user else { return }
        
        if otherUser  == .following {
            otherUser = .notFollowing
            followButton.setTitle("Follow", forState: .Normal)
            UserController.sharedController.removeSubscriptionToUser(user, completion: { (success, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            
        } else {
            otherUser = .following
            followButton.setTitle("Unfollow", forState: .Normal)
            UserController.sharedController.addSubscriptionToUser(user, alertBody: "AAA!", completion: { (success, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    func updateWithUser(user: User) {
        usernameLabel.text = user.username
        self.user = user
        
    }
    
    // MARK: - Actions
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        updateFollowButton()
    }
}
