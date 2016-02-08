//
//  TwitterTrovUITests.swift
//  TwitterTrovUITests
//
//  Created by Jake Hargus on 2/6/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import XCTest

class TwitterTrovUITests: XCTestCase {
        
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
    
    func testEmptyLogin() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Login"].tap()
        XCTAssert(app.alerts["Login Failed"].exists)
        app.alerts["Login Failed"].collectionViews.buttons["OK"].tap()
        
        
    }
    
    func testCreateUserPasswordMismatch() {
        
        let app = XCUIApplication()
        app.buttons["Create Account"].tap()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("Test")
        
        let passwordTextField = app.textFields["Password"]
        passwordTextField.tap()
        passwordTextField.tap()
        passwordTextField.typeText("1234")
        
        let confirmPasswordTextField = app.textFields["Confirm Password"]
        confirmPasswordTextField.tap()
        confirmPasswordTextField.tap()
        confirmPasswordTextField.typeText("12345")
        app.buttons["Save"].tap()
        XCTAssert(app.alerts["Password Mismatch"].exists)
        app.alerts["Password Mismatch"].collectionViews.buttons["OK"].tap()
        
    }
    
}
