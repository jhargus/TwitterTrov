//
//  AddUserViewController.swift
//  TwitterTrov
//
//  Created by Jake Hargus on 2/6/16.
//  Copyright © 2016 Blue Raccoon Software. All rights reserved.
//

import UIKit

class AddUserViewController: UIViewController {
    
    @IBOutlet var txbUsername: UITextField!
    @IBOutlet var txbPassword: UITextField!
    @IBOutlet var txbConfirmPassword: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTap(sender: AnyObject) {
        
        do {
            
            //I could check the confirm where clause here to see if it's equal to password since password has already been checked
            //but I want to trap that validation error separately to give the user a more meaningful prompt
            guard let username = self.txbUsername.text where username.isEmpty == false,
                let password = self.txbPassword.text where password.isEmpty == false,
                let confirm = self.txbConfirmPassword.text where confirm.isEmpty == false else {
                   
                    AppManager.showSimpleAlert("Incomplete Data", message: "Please fill out all text fields before tapping the save button.")
                    return
            }
            
            if confirm != password {
                AppManager.showSimpleAlert("Password Mismatch", message: "Password text does not match")
                return
            }
            
            try DataManager.addUser(username, password: password, email: "")
            AppManager.loginUser(username)
            
            try DataManager.addTweet(username, message: "My first tweet")
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.view.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        } catch let error {
            AppManager.showSimpleAlert("Save Failed", message: "Unable to save user: \(error)")
        }
        
    }
    
    @IBAction func cancelButtonTap(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.view.endEditing(true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
