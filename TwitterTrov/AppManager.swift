//
//  DefaultsManager.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/6/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit

struct AppManager {
    
    //Mark : Login State
    static func getLoggedInUserName() -> String? {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        return defaults.valueForKey("ActiveUserName_Setting") as? String
        
    }
    
    static func loginUser(username: String) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(username, forKey: "ActiveUserName_Setting")
        
    }
    
    static func logoutUsers() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(nil, forKey: "ActiveUserName_Setting")
        
    }
    
    //Mark : UI Utilities
    
    static func getTopViewController() -> UIViewController? {
        
        if var topViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let vc = topViewController.presentedViewController {
                topViewController = vc
            }
            
            return topViewController
        }
        
        return nil
    }
    
    static func showSimpleAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: "Login Failed", message: "Username and password are required in order to login.", preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        
        alert.addAction(cancel)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //This could produce a nil view controller so this message could get lost. I think it's safe enough
            //for a quick demo project though
            AppManager.getTopViewController()?.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
}