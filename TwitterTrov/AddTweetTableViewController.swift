//
//  AddTweetTableViewController.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/7/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit

class AddTweetTableViewController: UITableViewController {

    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var txfTweet: UITextView!
    
    var currentUserName : String = "" {
        didSet {
            self.lblUsername.text = self.currentUserName ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = AppManager.getLoggedInUserName() else {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    AppManager.showLogin()
                })
            })
            
            return
        }
        
        self.currentUserName = user
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.txfTweet.becomeFirstResponder()
    }


    @IBAction func postTapped(sender: AnyObject) {
        
        guard let tweetText = self.txfTweet.text where tweetText.isEmpty == false else {
            AppManager.showSimpleAlert("Error", message: "Tweet text cannot be empty")
            return
        }
        
        do {
            
            try DataManager.addTweet(self.currentUserName, message: tweetText)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
        } catch DataManager.DataError.UserNotFound {
            AppManager.showSimpleAlert("User Not Found", message: "Unable to find user account. Please logout and try again")
        } catch {
            AppManager.showSimpleAlert("Post Failed", message: "Unable to post tweet.")
        }
        
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
