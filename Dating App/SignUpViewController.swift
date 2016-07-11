//
//  SignUpViewController.swift
//  
//
//  Created by Dustin Allen on 7/10/16.
//
//

import UIKit
import FBSDKLoginKit
import TwitterKit
import Fabric
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var phoneField: UITextField!
    var ref:FIRDatabaseReference!
    
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.phoneField.delegate = self
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func createProfile(sender: AnyObject) {
        let email = self.emailField.text!
        let password = self.passwordField.text!
        // make sure the user entered both email & password
        if email != "" && password != "" {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion:  { (user, error) in
                if error == nil {
                    FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
                    self.ref.child("users").child(user!.uid).setValue(["userFirstName": self.firstNameField.text!, "userLastName": self.lastNameField.text!, "userPhoneNumber": self.phoneField.text!])
                    CommonUtils.sharedUtils.hideProgress()
                    let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController!
                    self.navigationController?.pushViewController(photoViewController, animated: true)
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
}
