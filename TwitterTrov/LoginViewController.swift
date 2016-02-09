//
//  LoginViewController.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/6/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit

enum LoginError : ErrorType {
    case loginInfoIncomplete
    case loginInvalid
}

//This is just a protocol to tell the delegate that the app logged in. I could have added an observer to the logged in username maybe,
//or used a callback. I think this was a little easier though for something so quick.
protocol LoginViewControllerDelegate {
    func loginComplete()
}

class LoginViewController: UIViewController {
    
    @IBOutlet var txbUsername: UITextField!
    @IBOutlet var txbPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var btnCreateAccount: UIButton!
    
    @IBOutlet var txbAddUsername: UITextField!
    @IBOutlet var txbAddPassword: UITextField!
    @IBOutlet var txbAddConfirm: UITextField!
    
    //I had the add user as it's own view controller for awhile. I didn't want to manage state of showing add/login UI.
    //However, I wanted it to dismiss the login and the add user screen and log in a user after adding the user (adding a user then 
    //logging in wasn't ideal). This turned out to be easier than managing multiple popups or deciding if the login screen was needed
    @IBOutlet var vwAddUser: UIView!
    
    //I'll use this loading view for the asynchronous time between login and a response (which will probably be so fast you won't see it)
    @IBOutlet var loadingView: UIVisualEffectView!
    
    //Delegate for notifying that login happened
    var delegate:LoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    //Button tap event for login
    @IBAction func loginTapped(sender: AnyObject) {
        
        do {
            //I abstracted this out of the tap, since there's some block handling I thoght it might be best to abstract it. 
            //I could have passed in the username and password here to make it more autonomous.
            try self.login()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadingView.hidden = false
            })
            
            //since I made this asynchronous I don't need all these error handlers since they're handled in the callback now.
            //I'll leave them in for now just in case I rethink that
        } catch LoginError.loginInfoIncomplete {
            AppManager.showSimpleAlert("Login Failed", message: "Please provide username and password in order to login.")
        } catch DataManager.DataError.UserNotFound {
            AppManager.showSimpleAlert("User Not Found", message: "Please check your username and try again.")
        } catch LoginError.loginInvalid{
            AppManager.showSimpleAlert("Login Failed", message: "Your username did not match your password. Please check your username and password and try again.")
        } catch {
            AppManager.showSimpleAlert("Login Failed", message: "The application failed to authenticate your account.")
        }
        
    }
    
    //button tap for opening the add user view
    @IBAction func createUserTapped(sender: AnyObject) {
        
        //Just going to clear the UI fields here and show the add view. This shoudld be done on the main thread
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.txbAddConfirm.text = ""
            self.txbAddPassword.text = ""
            self.txbAddUsername.text = ""
            
            self.vwAddUser.hidden = false
        }
        
    }
    
    //button press for saving a user
    @IBAction func saveUserTapped(sender: AnyObject) {
        
        do {
            
            //I could check the confirm where clause here to see if it's equal to password since password has already been checked
            //but I want to trap that validation error separately to give the user a more meaningful prompt.
            guard let username = self.txbAddUsername.text where username.isEmpty == false,
                let password = self.txbAddPassword.text where password.isEmpty == false,
                let confirm = self.txbAddConfirm.text where confirm.isEmpty == false else {
                    
                    AppManager.showSimpleAlert("Incomplete Data", message: "Please fill out all text fields before tapping the save button.")
                    return
            }
            
            //check for equality here to have a more specific error message
            if confirm != password {
                AppManager.showSimpleAlert("Password Mismatch", message: "Password text does not match")
                return
            }
            
            //add the user
            try DataManager.addUser(username, password: password, email: "")
            //set the user in defaults
            AppManager.loginUser(username)
            
            //create a first tweet for the user. This was really just a cheap way to avoid having to display a "no tweets" message in the table
            try DataManager.addTweet(username, message: "My first tweet")
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.view.endEditing(true)
                self.delegate?.loginComplete()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            //just going to trap any error the same way and tell the user.
        } catch let error {
            AppManager.showSimpleAlert("Save Failed", message: "Unable to save user: \(error)")
        }
        
    }
    
    //this should just hide the add view and put the user back at the empty login view
    @IBAction func cancelAddUserTapped(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.txbUsername.text = ""
            self.txbPassword.text = ""
            self.vwAddUser.hidden = true
        }
        
    }
    
    
    //Login method
    func login() throws {
        
        //make sure there username and password aren't blank
        guard let username = self.txbUsername.text where username.isEmpty == false,
              let password = self.txbPassword.text where password.isEmpty == false else {
                
                throw LoginError.loginInfoIncomplete
        }
        //TODO: show loading view
        
        //call async login
        DataManager.validateUser(username, password: password, callback: { (success, error) -> Void in
            
            //this animate in out will likely happen so fast you fast you can't see it
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadingView.hidden = true
            })
            
            //login the user if successful, notify the user if not
            if success == true {
                AppManager.loginUser(username)
                self.delegate?.loginComplete()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                
                if error != nil {
                    AppManager.showSimpleAlert("User Not Found", message: "Please check your username and try again.")
                } else {
                    AppManager.showSimpleAlert("Login Failed", message: "Your username did not match your password. Please check your username and password and try again.")
                }
                
            }
            
        })

    }
    

}
