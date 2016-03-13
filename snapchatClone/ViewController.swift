//
//  ViewController.swift
//  snapchatClone
//
//  Created by Forrest Collins on 7/30/15.
//  Copyright (c) 2015 Forrest Collins. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //-------------------
    // MARK: - UI Outlets
    //-------------------
    @IBOutlet weak var usernameTextField: CustomTextField!
    
    //-----------------------------
    // MARK: - View Did Load
    //         Lazy Login & Sign Up
    //-----------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        // CHECK
        if PFUser.currentUser() == nil {
            print("no users logged in")
        } else {
            print("user is logged in")
        }
    }
    
    //---------------------------
    // MARK: - View Did Appear
    //         Show users to snap
    //---------------------------
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            
            self.performSegueWithIdentifier("showUsers", sender: self)
        }
    }
    
    //------------------------------
    // MARK: - Sign in Button Tapped
    //         Lazy Login & Sign Up
    //------------------------------
    @IBAction func signinButtonTapped(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: "mypass") { (user, error) in
            if user != nil {
                
                print("logged in")
                
                self.performSegueWithIdentifier("showUsers", sender: self)
                
            } else {
                
                // user doesn't exist, sign up
                let user = PFUser()
                user.username = self.usernameTextField.text
                user.password = "mypass"
                
                user.signUpInBackgroundWithBlock { (success, error) -> Void in
                    if error == nil {
                        print("signed up")
                    } else {
                        print(error)
                    }
                }
            }
        }
    }
}

