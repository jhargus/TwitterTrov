//
//  TweetTableViewCell.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/7/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var vwCard: UIView!
    
    //setup the cell when the tweet is set
    var tweet : TRVTweets! {
        didSet {
            self.lblName.text = tweet.user?.username ?? ""
            self.lblMessage.text = tweet.tweetMessage ?? ""
            
            let df = NSDateFormatter()
            df.dateStyle = NSDateFormatterStyle.LongStyle
            df.timeStyle = NSDateFormatterStyle.MediumStyle
            
            if tweet.timeStamp != nil {
                self.lblDate.text = df.stringFromDate(tweet.timeStamp!)
            }
        }
    }

    //set the corner radius after awake
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imgProfile.layer.cornerRadius = 31.0
        self.vwCard.layer.cornerRadius = 15.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
