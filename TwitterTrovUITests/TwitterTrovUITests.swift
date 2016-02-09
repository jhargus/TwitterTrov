//
//  TwitterTrovUITests.swift
//  TwitterTrovUITests
//
//  Created by Jake Hargus on 2/8/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import XCTest

class TwitterTrovUITests: XCTestCase {
    
    //I've never done these either, but I wanted to try testing out a few of the obvious validation cases
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyCredentials() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        app.buttons["Login"].tap()
        XCTAssertTrue(app.alerts["Login Failed"].exists)
        app.alerts["Login Failed"].collectionViews.buttons["OK"].tap()

    }
    
    func testEmptyPassword(){
        
        let app = XCUIApplication()
        let usernameTextField = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextField)["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("12345125215125215")
        app.buttons["Login"].tap()
        XCTAssertTrue(app.alerts["Login Failed"].exists)
        app.alerts["Login Failed"].collectionViews.buttons["OK"].tap()
        
    }
    
    func testEmptyUsername(){
        
        
        let app = XCUIApplication()
        let usernameTextField = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.TextField)["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("123453")
        app.buttons["Login"].tap()
        XCTAssertTrue(app.alerts["Login Failed"].exists)
        app.alerts["Login Failed"].collectionViews.buttons["OK"].tap()
        
        
    }
    
    
    
}
