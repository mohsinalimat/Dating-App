//
//  SettingsViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 7/3/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import OAuthSwift

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var facebook: UIButton!
    @IBOutlet var twitter: UIButton!
    @IBOutlet var instagram: UIButton!
    @IBOutlet var linkedIn: UIButton!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet weak var friendRequests: UILabel!
    
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.emailField.delegate = self
        self.phoneField.delegate = self
        self.friendRequests.hidden = true
        
        //Mark check inbox
        checkInbox()
        
    }
    @IBAction func facebookLogin(sender: AnyObject) {
        
        let manager = FBSDKLoginManager()
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        manager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self) { (result, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print(error.localizedDescription)
            }
            else if result.isCancelled {
                print("Facebook login cancelled")
            }
            else {
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information...")
                let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,email,gender,friends,picture"])
                graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    CommonUtils.sharedUtils.hideProgress()
                    if ((error) != nil) {
                        // Process error
                        print("Error: \(error)")
                    } else {
                        print("fetched user: \(result)")
                        self.ref.child("users").child(self.user!.uid).child("facebookData").setValue(["userFirstName": result.valueForKey("first_name") as! String!, "userLastName": result.valueForKey("last_name") as! String!, "gender": result.valueForKey("gender") as! String!, "email": result.valueForKey("email") as! String!])
                        if let picture = result.objectForKey("picture") {
                            if let pictureData = picture.objectForKey("data"){
                                if let pictureURL = pictureData.valueForKey("url") {
                                    print(pictureURL)
                                    self.ref.child("users").child(self.user!.uid).child("facebookData").child("profilePhotoURL").setValue(pictureURL)
                                }
                            }
                        }
                        self.facebook.titleLabel?.text = "Facebook Added"
                    }
                })
            }
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func createProfile(sender: AnyObject) {
        let email = self.emailField.text!
        // make sure the user entered both email & password
        if email != "" {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(email, password: "nil", completion:  { (user, error) in
                if error == nil {
                    FIREmailPasswordAuthProvider.credentialWithEmail(email, password: "nil")
                    self.ref.child("users").child(user!.uid).setValue(["userFirstName": self.firstNameField.text!, "userLastName": self.lastNameField.text!, "userPhoneNumber": self.phoneField.text!])
                    CommonUtils.sharedUtils.hideProgress()
                    let signUpSocialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpSocialViewController") as! SignUpSocialViewController!
                    self.navigationController?.pushViewController(signUpSocialViewController, animated: true)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        CommonUtils.sharedUtils.hideProgress()
                        CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                    })
                }
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "Enter email & password!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
        }
        /*
         func setDisplayName(user: FIRUser) {
         let changeRequest = user.profileChangeRequest()
         changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
         changeRequest.commitChangesWithCompletion(){ (error) in
         if let error = error {
         print(error.localizedDescription)
         return
         }
         self.signedIn(FIRAuth.auth()?.currentUser)
         }
         }
         
         func signedIn(user: FIRUser?) {
         MeasurementHelper.sendLoginEvent()
         
         AppState.sharedInstance.displayName = user?.displayName ?? user?.email
         AppState.sharedInstance.photoUrl = user?.photoURL
         AppState.sharedInstance.signedIn = true
         NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
         performSegueWithIdentifier(Constants.Segues.AddSocial, sender: nil)
         }
         }*/
    }

    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func inboxButton(sender: UIButton) {
        self.performSegueWithIdentifier("SettingsToInbox", sender: self)
    }
    
    func checkInbox() -> Void {
        let userId = FIRAuth.auth()?.currentUser?.uid
        let ref = self.ref.child("users").child(userId!).child("friendRequests")
        
        ref.observeEventType(.Value, withBlock: { snapshot in
                let count = snapshot.children.allObjects.count
                self.friendRequests.text = String(count)
            
                if count > 0 {
                    self.friendRequests.hidden = false
                } else {
                    self.friendRequests.hidden = true
                }
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        
    }
    
    @IBAction func logOutButton(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        AppState.sharedInstance.signedIn = false
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignInViewController") as! FirebaseSignInViewController!
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
}
