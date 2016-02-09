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
    
    //Error codes specific to the data manager. These can be used by code to determine what happened
    //or to pass on information to the user
    enum DataError : ErrorType {
        case AppDelegateNotFound
        case UserNotFound
        case UserAlreadyExists
    }
    
    // MARK: Reads
    
    //This will read all tweets for the provided username and return them synchronously. It'll throw an error
    //if it cannot get the main context or if the fetch request fails. For this one I'm not going to convert everything
    //to lower case so the username will be case sensitive
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
    
    //This will get the user Managed Object for the username. It can return a null, which allows the other methods to deal
    //with a username that is not set instead of throwing an error itself. I think the right approach to these is to try and 
    //hand back a non optional or throw an error (at least in Swift 2.0). In this case it made a little more sense to hand back the optional.
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
    
    //This will synchronously get tweets with a timestamp later than the date provided. This is used to update the UI with only
    //tweets that are new
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
    
    /*This is an asynchronous method to validate a user. In this case I don't believe I can throw because it's not going to happen
    immediately. As a result I'll have to hand back any errors that occur. This seems to be the pattern that Apple follows
    with NSError still being used for some async operations. Another thing to note is that I explicitly name the parameters
    in the callback signature. This isn't required but since the DataManager class might typically be found in somethign like a framework,
    it's important for anyone who consumes this to know what those parameters mean when they come back.
    
    In order for this to happen asynchronously I'm dispatching it to the background. This will jump the execution in the dispatch_async
    block so that the caller will continue operating while this happens somewhere else. The caller can use the callback then to 
    process the results and update their UI or data. 
    
    Another thing to note is that the NSManagedObjectContext is not really thread safe. In one of my current apps I create a background context
    for each thread that spawns where database changes are needed. These contexts are children of the main context and their updates will
    be pushed there on save and merged. In that app I actually have the write context on a background thread as well to speed up big writes. In
    this case though, we're not mutating any data and there isn't any other database concurrency happening so reading from the background shouldn't be an issue.
    */
    static func validateUser(username: String, password: String, callback:((success: Bool, error: ErrorType?) -> Void))  {
        
        let backgroundQueue = dispatch_queue_create("Validate Queue", nil)
        dispatch_async(backgroundQueue) { () -> Void in
            
            do {
                
                guard let user = try DataManager.getUser(username) else {
                    throw DataError.UserNotFound
                }
                
                //I could throw a custom error here instead of returning false as well. May have to do that if I decide to do these Async
                if user.password != password {
                    return callback(success: false, error:nil)
                } else {
                    return callback(success: true, error:nil)
                }
                
            } catch let error {
                return callback(success: false, error: error)
            }
        }
            
        
        
        
    }
    
    // MARK: Writes
    
    //This adds a new user, it'll throw an error if the user already exists or if it can't find the main context. It'll also throw
    //any database errors that are encounted on save
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
    
    //This will add a new tweet for a user. It can throw an error if it can't find the user or if the save fails
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
    
    //this is just a convienence method to get the main context. It's mostly so I don't have to grab the app delegate
    //everytime I want to get it. It also throws an error if I can't grab the app delegate
    static func getMainContext() throws -> NSManagedObjectContext {
        
        guard let appDel = UIApplication.sharedApplication().delegate as? AppDelegate else {
            //TODO: throw
            throw DataError.AppDelegateNotFound
        }
        
        return appDel.managedObjectContext
        
    }
    
}