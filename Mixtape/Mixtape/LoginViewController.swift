//
//  LoginViewController.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/8/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
    usernameTextField.hidden = true
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var accountButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    enum Account {
        case existing
        case new
    }
    
    var account = Account.existing
    
    func updateLoginView() {
        if account == .existing  {
            account = .new
            usernameTextField.hidden = false
            accountButton.setTitle("Need an account?", forState: .Normal)
        } else {
            account = .existing
            usernameTextField.hidden = true
            accountButton.setTitle("Have an account", forState: .Normal)
        }
    }
    
    func checkForAccount() {
        if account == .existing {
            let allUsers = UserController.sharedController.users
            for user in allUsers {
                if user.username == usernameTextField.text {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyBoard.instantiateViewControllerWithIdentifier("PlaylistViewController")
                    self.presentViewController(viewController, animated: true, completion: nil)
                }
            }
        } else {
            if account == .new {
                if let username = usernameTextField.text where username.characters.count > 0 {
                    UserController.sharedController.createUser(username)
                    
                    
                }
            }
        }
    }
    
    @IBAction func accountButtonTapped(sender: AnyObject) {
        updateLoginView()
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        checkForAccount()
    }
    
    
}

