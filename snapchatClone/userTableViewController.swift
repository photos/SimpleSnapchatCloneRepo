//
//  userTableViewController.swift
//  snapchatClone
//
//  Created by Forrest Collins on 7/30/15.
//  Copyright (c) 2015 Forrest Collins. All rights reserved.
//

// TODO: Make it so the user will not recieve another popup message until the image has been dismissed
// TODO: Make it so the user cannot upload a second image until the image they are uploading is done

import UIKit
import Parse
import ParseUI

class userTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //--------------------------
    // MARK: - Global Variables
    //--------------------------
    var userArray = [String]()
    
    var activeRecipient = 0
    
    var timer = NSTimer()
    
    //--------------------------
    // MARK: - Alert Controller
    //--------------------------
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    //---------------------------------
    // MARK: - Image Picker Controller
    //---------------------------------
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let imageToSend = PFObject(className: "image")
        
        imageToSend["photo"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.75)!)
        imageToSend["senderUsername"] = PFUser.currentUser()?.username
        imageToSend["recipientUsername"] = userArray[activeRecipient]
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        //-----------------------------
        // MARK: - Save Photo to Parse
        //-----------------------------
        imageToSend.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error != nil {
                self.displayAlert("Error", message: "Image failed to send")
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            } else {
                
                self.displayAlert("Nice!", message: "Image was sent successfully")
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
    }
    
    //------------------------------------------
    // MARK: - Pick an Image to display or edit
    //------------------------------------------
    func pickImageButtonTapped(sender: AnyObject) {
        
        let pickedImage = UIImagePickerController()
        pickedImage.delegate = self
        pickedImage.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        pickedImage.allowsEditing = false
        
        self.presentViewController(pickedImage, animated: true, completion: nil)
        
    }
    
    //-----------------------------------------------------------------------
    // MARK: - When your view appears, check to see if you have any messages
    //-----------------------------------------------------------------------
    override func viewDidAppear(animated: Bool) {
        
        // start timer at beginning of app, check for messages every 2 seconds
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("checkForMessage"), userInfo: nil, repeats: false)
    }
    
    //------------------------------------------
    // MARK: - Query a list of users in a table
    //------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide empty table view cells
        let bgView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = bgView
        self.tableView.backgroundColor = UIColor.whiteColor()
        
        let query = PFUser.query()
        
        if PFUser.currentUser()?.username != nil {
            
            query?.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
            
            if let users = query?.findObjects() {
                
                for user in users {
                    
                    print(user.username as String!)
                    userArray.append(user.username as String!)
                    
                    tableView.reloadData()
                }
            }
        }
    }
    
    //--------------------------
    // MARK: - Check for Message
    //--------------------------
    func checkForMessage() {
        
        let query = PFQuery(className: "image")
        
        // checking if there is a new image for user
        if PFUser.currentUser()?.username != nil {
            
            // check if you are the recipient
            query.whereKey("recipientUsername", equalTo: PFUser.currentUser()!.username!)
            
            if let images = query.findObjects() {
                
                var done = false // not found picture
                
                for image in images {
                    
                   // loop thru images
                    if done == false {
                        
                        // load the image
                        let imageView : PFImageView = PFImageView()
                        imageView.file = image["photo"] as? PFFile
                        
                        imageView.loadInBackground( {(photo, error) -> Void in
                        
                            // create string of the sender's username
                            if error == nil {
                                
                                var senderUsername = ""
                                
                                if image["senderUsername"] != nil {
                                    
                                    senderUsername = image["senderUsername"] as! NSString as String
                                    
                                } else {
                                    
                                    senderUsername = "someone"
                                }
                                
                                
                            // alert user when the photo has been downloaded
                            let alert = UIAlertController(title: "You have a message", message: "Message from \(senderUsername)", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title : "OK", style: .Default, handler: {
                                    (action) -> Void in
                                    
                            // give darkened background view
                            let backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                            backgroundView.backgroundColor = UIColor.blackColor()
                            backgroundView.alpha = 0.8
                                
                            backgroundView.tag = 3
                                
                            self.view.addSubview(backgroundView)
                                
                            // display the photo
                            let displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                
                            displayedImage.image = photo
                                
                            displayedImage.tag = 3
                                
                            displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                                
                            // when photo is actually displayed
                            self.view.addSubview(displayedImage)
                                
                                
                            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                                
                            // delete image from Parse once recieved
                            image.delete()
                                
                            // show & hide image after 5 seconds
                            self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                                    
                                }))
                                
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        })
                        
                        done = true
                    }
                }
            }
        }
    }
    
    //---------------------
    // MARK: - Hide Message
    //---------------------
    func hideMessage() {
        
        // remove the two views with a tag of 3 and remove them
        // loop thru all the subviews
        for subview in self.view.subviews {
            if subview.tag == 3 {
                
                subview.removeFromSuperview()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                // shows new message after other message is dismissed after a 2 second interval
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("checkForMessage"), userInfo: nil, repeats: false)
            }
        }
    }

    //---------------------------------------------
    // MARK: - Table View Number of Rows in Section
    //---------------------------------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }

    //----------------------------------------------
    // MARK: - Table View Cell for Row at Index Path
    //----------------------------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 

        cell.textLabel?.text = userArray[indexPath.row] // this is where I can randomize actually, the activeRecipient is this user that is randomly selected

        return cell
    }
    
    //------------------------------------------------
    // MARK: - Table View Did Select Row at Index Path
    //------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        activeRecipient = indexPath.row
        
        pickImageButtonTapped(self)
    }
    
    //--------------------------
    // MARK: - Prepare for Segue
    //--------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutSegue" {
            
            if PFUser.currentUser() != nil {
                PFUser.logOut()
            }
        }
    }
}
