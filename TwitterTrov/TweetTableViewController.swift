//
//  TweetTableViewController.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/6/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, LoginViewControllerDelegate, AddTweetTableDelegate {

    //This variable will hold the list of tweets. This is a lot easier to do with an NSFetchResultsController
    //since you get notifications when the table changes and can reload automatically. I wanted to pretend we 
    //were accessing data from an external source though.
    var tweets : [TRVTweets] = [TRVTweets]()
    
    //This will hold the most recent tweet date so I can just load new ones as they come
    var lastDate = NSDate.distantPast()
    
    //MARK : View Controller Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load tweets initially
        self.loadTweets()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //this is used for setting the delegate during a segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddTweetSegue" {
            
            //Don't like these force unwraps. They'll work for now though
            let addTweetNav = segue.destinationViewController as! UINavigationController
            let addTweetController = addTweetNav.topViewController as! AddTweetTableViewController
            addTweetController.delegate = self
            
        }
    }
    
    //Mark : IBActions
    
    //button tap for logout
    @IBAction func logout(sender: AnyObject) {
        
        AppManager.logoutUsers()
        lastDate = NSDate.distantPast()
        AppManager.showLogin(self)
        
    }
    
    //pull down to refresh the table.
    @IBAction func refreshTable(sender: UIRefreshControl) {
        self.updateTweets()
        sender.endRefreshing()
    }
    
    
    
    // MARK: manage tweets
    
    //this will load all tweets and reinitialize the tweet array. We want to do this on load or when a user is logged in
    //as they might not be the same user as last time and we don't want to append to those other tweets
    func loadTweets() {
        
        do {
            
            //if the user isn't available we'll set last date back to distant past. that would allow updates
            //to work as well
            guard let username = AppManager.getLoggedInUserName() else {
                AppManager.showLogin(self)
                lastDate = NSDate.distantPast()
                return
            }
            
            //try to get tweets then reload the whole table
            tweets = try DataManager.getTweetsForUser(username)
            if tweets.count > 0 {
                
                if let latestTimeStamp = tweets.first?.timeStamp {
                    self.lastDate = latestTimeStamp
                }
                
                self.tableView.reloadData()
            }
            
        } catch {
            AppManager.showSimpleAlert("Load Failed", message: "Unable to get tweets")
        }
    }
    
    /*
    I should note that this is for mimicing a web service call. In a normal situation I'd just use a protocol or callback to update the table
    since the only way the table is appended to is via adding a new tweet locally. However, in the case of a web service we might want it to
    make the web service call then grab the new tweet from the server instead of just grabbing the values we created in a post (for example the
    server might assign a UUID or other identifier to the tweet so we might not have the complete data object without a service call).
    
    Here I'm inserting the new values per the requirements and not reloading all data. I think this is more inline with what the requirements are asking for with "on subsequent launches, automatically display older tweets and only query for newer ones"
    */
    func updateTweets(){
        
        
        do {
            //again check to see if the user exists first
            guard let username = AppManager.getLoggedInUserName() else {
                AppManager.showLogin(self)
                lastDate = NSDate.distantPast()
                return
            }
            
            //try to get new tweets since the last time we got a tweet
            let newTweets = try DataManager.getNewTweets(username, sinceDate: self.lastDate)
            if newTweets.count > 0 {
                
                //if there are new tweets set the last time stamp
                if let latestTimeStamp = newTweets.first?.timeStamp {
                    self.lastDate = latestTimeStamp
                }
                
                var indexPaths = [NSIndexPath]()
                let startingIndex = newTweets.count - 1
                
                //iterate backwards and insert tweets and add them to the beginnig. This should maintain order
                for index in startingIndex.stride(through: 0, by: -1) {
                    let newIndex = NSIndexPath(forRow: index, inSection: 0)
                    indexPaths.append(newIndex)
                    
                    self.tweets.insert(newTweets[index], atIndex: 0)
                }
                
                //start updating and insert new rows
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                self.tableView.endUpdates()
                
                
            }
            //we'll handle all errors the same way here
        } catch {
            AppManager.showSimpleAlert("Load Failed", message: "Unable to get tweets")
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tweets.count
    }
    
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetTableViewCell
        
        //just going to use a custom cell here so I don't have to set all the data elements by tag
        cell.tweet = self.tweets[indexPath.row]
        return cell
    }
    
    //MARK : LoginControllerDelegate methods
    func loginComplete() {
        self.loadTweets()
    }
    
    //MARK : AddTweetTableDelegate methods
    func tweetAdded() {
        self.updateTweets()
    }

}
