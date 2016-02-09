//
//  TwitterTrovTests.swift
//  TwitterTrovTests
//
//  Created by Jake Hargus on 2/6/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import XCTest
@testable import TwitterTrov

class TwitterTrovTests: XCTestCase {
    
    let testUsername = "test1234567890"
    
    //I'm going to call deleteTestData on setup and tear down just in case. I've never written these before so I'm not really sure if this is
    //right. This should cover all the basic datamanager operations though

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        deleteTestData()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        deleteTestData()
        
        super.tearDown()
    }
    
    func deleteTestData(){
        do{
            let context = try DataManager.getMainContext()
            if let testUser = try DataManager.getUser(testUsername) {
                context.deleteObject(testUser)
            }
            
        } catch let error{
            print("error deleting: \(error)")
        }
    }
    
    func testAddUser() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        do {
            try DataManager.addUser(testUsername, password: "1234", email: "")
        } catch let error{
            XCTAssert(false, "Error: \(error)")
        }
        
    }
    
    func testDuplicateUser(){
        //should be added in the above test
        var errorThrown = false
        
        do {
            try DataManager.addUser(testUsername, password: "1234", email: "")
            try DataManager.addUser(testUsername, password: "1234", email: "")
        } catch DataManager.DataError.UserAlreadyExists {
            errorThrown = true
        } catch {
            
        }
        
        XCTAssert(errorThrown)
    }
    
    func testPostTweet(){
        
        do{
            try DataManager.addUser(testUsername, password: "1234", email: "")
            
            try DataManager.addTweet(testUsername, message: "Test Tweet 1")
            try DataManager.addTweet(testUsername, message: "Test Tweet 2")
        } catch {
            XCTAssert(false, "Error: \(error)")
        }
        
    }
    
    func testReadTweets(){
        do{
            try DataManager.addUser(testUsername, password: "1234", email: "")
            
            try DataManager.addTweet(testUsername, message: "Test Tweet 1")
            try DataManager.addTweet(testUsername, message: "Test Tweet 2")
            
            let tweets = try DataManager.getTweetsForUser(testUsername)
            XCTAssertTrue(tweets.count == 2, "Tweet count: \(tweets.count)")
            
        } catch {
            XCTAssert(false, "Error: \(error)")
        }
    }
    
}
