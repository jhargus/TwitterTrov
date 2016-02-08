//
//  TweetHeader.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/7/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit

class TweetHeader: UITableViewHeaderFooterView {

    
    @IBAction func createTweet(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tweetController = storyboard.instantiateViewControllerWithIdentifier("TweetNavController")
        
        AppManager.getTopViewController()?.presentViewController(tweetController, animated: true, completion: nil)
        
    }

}
