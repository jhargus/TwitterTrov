//
//  TweetTableViewController.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/6/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController {

    var tweets : [TRVTweets] = [TRVTweets]()
    var lastDate = NSDate.distantPast()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerxib = UINib(nibName: "TweetHeader", bundle: nil)
        self.tableView.registerNib(headerxib, forHeaderFooterViewReuseIdentifier: "TweetHeader")
        
        self.loadTweets()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateTweets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tweets.count
    }
    
    func loadTweets() {
        
        do {
            
            guard let username = AppManager.getLoggedInUserName() else {
                AppManager.showLogin()
                return
            }
            
            tweets = try DataManager.getTweetsForUser(username)
            if tweets.count > 0 {
                
                if let latestTimeStamp = tweets.first?.timeStamp {
                    self.lastDate = latestTimeStamp
                }

                self.tableView.reloadData()
            }
            
        } catch {
            //TODO: alert here
        }
    }
    
    /*
    I should note that this is for mimicing a web service call. In a normal situation I'd just use a protocol or callback to update the table
    since the only way the table is appended to is via adding a new tweet locally. However, in the case of a web service we might want it to 
    make the web service call then grab the new tweet from the server instead of just grabbing the values we created in a post (for example the
    server might assign a UUID or other identifier to the tweet so we might not have the complete data object without a service call). 
    
    I might still reload the table depending on data sizes. Here I'm inserting the new values per the requirements and not reloading all data. 
    I think this is more inline with what the requirements are asking for with "on subsequent launches, automatically display older tweets and only query for newer ones"
    */
    func updateTweets(){

        
        do {
            
            guard let username = AppManager.getLoggedInUserName() else {
                AppManager.showLogin()
                return
            }
            

            let newTweets = try DataManager.getNewTweets(username, sinceDate: self.lastDate)
            if newTweets.count > 0 {
                
                if let latestTimeStamp = newTweets.first?.timeStamp {
                    self.lastDate = latestTimeStamp
                }
                
                var indexPaths = [NSIndexPath]()
                let startingIndex = newTweets.count - 1
                
                //iterate backwards and insert tweets
                for index in startingIndex.stride(through: 0, by: -1) {
                    let newIndex = NSIndexPath(forRow: index, inSection: 0)
                    indexPaths.append(newIndex)
                    
                    self.tweets.insert(newTweets[index], atIndex: 0)
                }
                
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                self.tableView.endUpdates()
                
            }
            
        } catch {
            AppManager.showSimpleAlert("Load Failed", message: "Unable to get tweets")
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetTableViewCell
        
        cell.tweet = self.tweets[indexPath.row]

        // Configure the cell...

        return cell
    }


    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("TweetHeader") {
            return cell as! TweetHeader
        }
        
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }

}
