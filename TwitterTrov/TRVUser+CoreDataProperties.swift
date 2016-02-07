//
//  TRVUser+CoreDataProperties.swift
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

extension TRVUser {

    @NSManaged var email: String?
    @NSManaged var password: String?
    @NSManaged var username: String?
    @NSManaged var tweets: NSSet?

}
