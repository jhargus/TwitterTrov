//
//  TRVTweets+CoreDataProperties.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/6/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TRVTweets {

    @NSManaged var timeStamp: NSDate?
    @NSManaged var tweetMessage: String?
    @NSManaged var user: TRVUser?

}
