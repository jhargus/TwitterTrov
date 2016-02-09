//
//  AddTweetTableViewController.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/7/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit

protocol AddTweetTableDelegate {
    func tweetAdded()
}

class AddTweetTableViewController: UITableViewController {

    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var txfTweet: UITextView!
    
    var delegate : AddTweetTableDelegate?
    
    //going to set the label on didSet so I don't have to worry about when setting it later
    var currentUserName : String = "" {
        didSet {
            self.lblUsername.text = self.currentUserName ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This shouldn't be able to happen. For now I'll just return if it does
        //I'd proabably spend a little more time on this for a production app
        guard let user = AppManager.getLoggedInUserName() else {
            return
        }
        
        self.currentUserName = user
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //pull the keyboard up and set the cursor in the message field
        self.txfTweet.becomeFirstResponder()
    }


    @IBAction func postTapped(sender: AnyObject) {
        //guard against an empty tweet
        guard let tweetText = self.txfTweet.text where tweetText.isEmpty == false else {
            AppManager.showSimpleAlert("Error", message: "Tweet text cannot be empty")
            return
        }
        
        do {
            
            //save the tweet, dismiss the view and call the delegate
            try DataManager.addTweet(self.currentUserName, message: tweetText)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.delegate?.tweetAdded()
                })
            
            })
            
        } catch DataManager.DataError.UserNotFound {
            AppManager.showSimpleAlert("User Not Found", message: "Unable to find user account. Please logout and try again")
        } catch {
            AppManager.showSimpleAlert("Post Failed", message: "Unable to post tweet.")
        }
        
    }
    
    //if cancel gets tapped we'll just dismiss
    @IBAction func cancelTapped(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
