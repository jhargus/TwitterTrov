//
//  DataManager.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/6/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit
import CoreData

struct DataManager {
    
    enum DataError : ErrorType {
        case AppDelegateNotFound
        case UserNotFound
        case UserAlreadyExists
    }
    
    // MARK: Reads
    static func getTweetsForUser(username: String) throws -> [TRVTweets] {
        
        do{
            let context = try DataManager.getMainContext()
            
            let fetchRequest = NSFetchRequest(entityName: "TRVTweets")
            
            let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let predicate = NSPredicate(format: "Any self.user.username == %@", argumentArray: [username])
            fetchRequest.predicate = predicate
            
            if let results : [TRVTweets] = try context.executeFetchRequest(fetchRequest) as? [TRVTweets] {
                return results
            } else {
                return [TRVTweets]()
            }

        } catch let error {
            throw error
        }

    }
    
    static func getUser(username: String) throws -> TRVUser? {
        
        do{
            let context = try DataManager.getMainContext()
            
            let fetchRequest = NSFetchRequest(entityName: "TRVUser")
            
            let predicate = NSPredicate(format: "username == %@", argumentArray: [username])
            fetchRequest.predicate = predicate
            
            fetchRequest.fetchLimit = 1
            
            if let result : [TRVUser] = try context.executeFetchRequest(fetchRequest) as? [TRVUser] {
                if result.count > 0 {
                    return result[0]
                } else {
                    return nil
                }
            } else {
                return nil
            }
            
        } catch let error {
            throw error
        }
        
    }
    
    static func getNewTweets(username: String, sinceDate: NSDate) throws -> [TRVTweets] {
        
        do{
            let context = try DataManager.getMainContext()
            
            let fetchRequest = NSFetchRequest(entityName: "TRVTweets")
            
            let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let predicate = NSPredicate(format: "Any self.user.username == %@ AND timeStamp > %@", argumentArray: [username, sinceDate])
            fetchRequest.predicate = predicate
            
            if let results : [TRVTweets] = try context.executeFetchRequest(fetchRequest) as? [TRVTweets] {
                return results
            } else {
                return [TRVTweets]()
            }
            
        } catch let error {
            throw error
        }
        
    }
    
    // MARK: Data Functions
    static func validateUser(username: String, password: String) throws -> Bool {
        do {
            
            guard let user = try DataManager.getUser(username) else {
                throw DataError.UserNotFound
            }
            
            //I could throw a custom error here instead of returning false as well. May have to do that if I decide to do these Async
            if user.password != password {
                return false
            } else {
                return true
            }
            
        } catch let error {
            throw error
        }
    }
    
    // MARK: Writes
    static func addUser(username: String, password: String, email: String) throws {
        
        do {
            
            if try DataManager.getUser(username) != nil {
                throw DataError.UserAlreadyExists
            }
            
            let context = try DataManager.getMainContext()
            let addedUser = NSEntityDescription.insertNewObjectForEntityForName("TRVUser", inManagedObjectContext: context) as! TRVUser
            addedUser.username = username
            addedUser.password = password
            addedUser.email = email
            
            try context.save()
            
            
        } catch let error{
            throw error
        }
        
    }
    
    static func addTweet(username: String, message: String) throws {
        
        do {
            
            guard let user = try DataManager.getUser(username) else {
                throw DataError.UserNotFound
            }
            
            let context = try DataManager.getMainContext()
            let tweet = NSEntityDescription.insertNewObjectForEntityForName("TRVTweets", inManagedObjectContext: context) as! TRVTweets
            tweet.timeStamp = NSDate()
            tweet.tweetMessage = message
            
            tweet.user = user
            
            try context.save()
            
            
        } catch let error{
            throw error
        }
        
    }
    
    
    // MARK: Utility Methods
    static func getMainContext() throws -> NSManagedObjectContext {
        
        guard let appDel = UIApplication.sharedApplication().delegate as? AppDelegate else {
            //TODO: throw
            throw DataError.AppDelegateNotFound
        }
        
        return appDel.managedObjectContext
        
    }
    
}