//
//  LogInViewController.swift
//  Dating App
//
//  Created by Dustin Allen on 7/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKShareKit
import Twitter
import TwitterKit
import Fabric

@objc(FirebaseSignInViewController)
class FirebaseSignInViewController: UIViewController {
    
    
    @IBOutlet var facebook: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet var twtter: UIButton!
    var ref:FIRDatabaseReference!
    
    override func viewDidAppear(animated: Bool) {
        //        try! FIRAuth.auth()?.signOut()
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
        }
        ref = FIRDatabase.database().reference()
    }
    
    @IBAction func didTapSignIn(sender: AnyObject) {
        
        // Sign In with credentials.
        let email = emailField.text!
        let password = passwordField.text!
        if email.isEmpty || password.isEmpty {
            CommonUtils.sharedUtils.showAlert(self, title: "Error", message: "Email or password is missing.")
        }
        else{
            CommonUtils.sharedUtils.showProgress(self.view, label: "Signing in...")
            FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    CommonUtils.sharedUtils.hideProgress()
                })
                if let error = error {
                    CommonUtils.sharedUtils.showAlert(self, title: "Error", message: error.localizedDescription)
                    print(error.localizedDescription)
                }
                else{
                    //                    self.signedIn(user!)
                    let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                    self.navigationController?.pushViewController(mainScreenViewController, animated: true)
                }
            }
        }
    }
    @IBAction func didTapSignUp(sender: AnyObject) {
        let signUpViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController!
        self.navigationController?.pushViewController(signUpViewController, animated: true)
        
    }
    
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
    
    @IBAction func didRequestPasswordReset(sender: AnyObject) {
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordResetWithEmail(userInput!) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        prompt.addTextFieldWithConfigurationHandler(nil)
        prompt.addAction(okAction)
        presentViewController(prompt, animated: true, completion: nil);
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
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(token)
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information...")
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        CommonUtils.sharedUtils.hideProgress()
                    }
                    else {
                        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,email,gender,friends,picture"])
                        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                            CommonUtils.sharedUtils.hideProgress()
                            if ((error) != nil) {
                                // Process error
                                print("Error: \(error)")
                            } else {
                                print("fetched user: \(result)")
                                self.ref.child("users").child(user!.uid).setValue(["facebookData": ["userFirstName": result.valueForKey("first_name") as! String!, "userLastName": result.valueForKey("last_name") as! String!, "gender": result.valueForKey("gender") as! String!, "email": result.valueForKey("email") as! String!], "userFirstName": result.valueForKey("first_name") as! String!, "userLastName": result.valueForKey("last_name") as! String!])
                                if let picture = result.objectForKey("picture") {
                                    if let pictureData = picture.objectForKey("data"){
                                        if let pictureURL = pictureData.valueForKey("url") {
                                            print(pictureURL)
                                            self.ref.child("users").child(user!.uid).child("facebookData").child("profilePhotoURL").setValue(pictureURL)
                                        }
                                    }
                                }
                                let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                                self.navigationController?.pushViewController(mainScreenViewController, animated: true)
                            }
                        })
                    }
                })
            }
        }
        
    }

    /*
    @IBAction func twitterLogin(sender: AnyObject) {
        
        let manager = Twitter()
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        manager.logInWithViewController(self) { (session, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                let token = session!.authToken
                let secret = session!.authTokenSecret
                
                let credential = FIRTwitterAuthProvider.credentialWithToken(token, secret: secret)
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information....")
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        CommonUtils.sharedUtils.hideProgress()
                        print(error?.localizedDescription)
                    }
                    else {
                        let client = TWTRAPIClient.clientWithCurrentUser()
                        let request = client.URLRequestWithMethod("GET",
                            URL: "https://api.twitter.com/1.1/account/verify_credentials.json",
                            parameters: ["include_email": "true", "skip_status":"true"],
                            error: nil)
                        
                        client.sendTwitterRequest(request){ (response, data, connectionError) -> Void in
                            CommonUtils.sharedUtils.hideProgress()
                            let profile = try! NSJSONSerialization.JSONObjectWithData(data!, options: [])
                            print(profile)
                            
                            self.ref.child("users").child(user!.uid).setValue(["twitterData": ["userFirstName": profile.valueForKey("name") as! String!, "userLastName": profile.valueForKey("screen_name") as! String!, "profile_image_url": profile.valueForKey("profile_image_url") as! String!, "url": profile.valueForKey("url") as! String!], "userFirstName": profile.valueForKey("name") as! String!, "userLastName": profile.valueForKey("screen_name") as! String!])
                            let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                            self.navigationController?.pushViewController(mainScreenViewController, animated: true)
                        }
                        
                    }
                })
            }
        }
    }*/
    
    func signedIn(user: FIRUser?) {
        let mainScreenViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
        self.navigationController?.pushViewController(mainScreenViewController, animated: true)
        //        MeasurementHelper.sendLoginEvent()
        //
        //        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        //        AppState.sharedInstance.photoUrl = user?.photoURL
        //        AppState.sharedInstance.signedIn = true
        //        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        //        performSegueWithIdentifier(Constants.Segues.AddSocial, sender: nil)
    }
    
}
