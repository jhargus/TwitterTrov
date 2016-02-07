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

class LoginViewController: UIViewController {
    
    @IBOutlet var txbUsername: UITextField!
    @IBOutlet var txbPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var btnCreateAccount: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func loginTapped(sender: AnyObject) {
        
        do {
            
            try self.login()
            
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
    
    
    func login() throws {
        
        guard let username = self.txbUsername.text where username.isEmpty == false,
              let password = self.txbPassword.text where password.isEmpty == false else {
                
                throw LoginError.loginInfoIncomplete
        }
        
        do {
            
            let isLogin = try DataManager.validateUser(username, password: password)
            
            if isLogin == true {
                //TODO: dismiss and save username
                AppManager.loginUser(username)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                throw LoginError.loginInvalid
            }
            
        } catch let error {
            throw error
        }
        
    }

}
