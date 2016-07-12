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
                   }

        // Do any additional setup after loading the view.
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var accountButton: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func accountButtonTapped(sender: AnyObject) {
    }
    
    @IBOutlet weak var loginButtonTapped: UIButton!
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

