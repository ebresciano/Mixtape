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
        super.viewDidLoad()
        
        usernameTextField.hidden = true
    }
    
    // Mark: - Outlets
    
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
            accountButton.setTitle("Have an account?", forState: .Normal)
            loginButton.setTitle("Create account", forState: .Normal)
        } else {
            account = .existing
            usernameTextField.hidden = true
            accountButton.setTitle("Need an account?", forState: .Normal)
            loginButton.setTitle("Login", forState: .Normal)
            
        }
    }
    
    func checkForAccount() {
        if account == .existing {
            if let _ = UserController.sharedController.users.first {
                performSegueWithIdentifier("toPlaylist", sender: self)
            } else {
                let alertController = UIAlertController(title: "Create an account", message: "Click on need an account!", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                    
                    presentViewController(alertController, animated: true, completion: nil)
                print("This person does not have an account")
            }
        } else {
            if let username = usernameTextField.text where username.characters.count > 0 {
                UserController.sharedController.createUser(username)
                performSegueWithIdentifier("toPlaylist", sender: self)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func accountButtonTapped(sender: AnyObject) {
        updateLoginView()
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        checkForAccount()
    }
    
    
}

