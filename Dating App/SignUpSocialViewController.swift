//
//  SignUpSocialViewController.swift
//  Dating App
//
//  Created by Dustin Allen on 7/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//


import Foundation
import Firebase
import TwitterKit
import FBSDKLoginKit
import FBSDKCoreKit
import OAuthSwift

class SignUpSocialViewController: UIViewController {
    
    @IBOutlet var facebook: UIButton!
    @IBOutlet var twitter: UIButton!
    @IBOutlet var instagram: UIButton!
    @IBOutlet var linkedIn: UIButton!
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
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
    
    @IBAction func twitterLogin(sender: AnyObject) {
        
        let manager = Twitter()
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        manager.logInWithViewController(self) { (session, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information....")
                let client = TWTRAPIClient.clientWithCurrentUser()
                let request = client.URLRequestWithMethod("GET",
                                                          URL: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                                          parameters: ["include_email": "true", "skip_status":"true"],
                                                          error: nil)
                
                client.sendTwitterRequest(request){ (response, data, connectionError) -> Void in
                    CommonUtils.sharedUtils.hideProgress()
                    let profile = try! NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    print(profile)
                    
                    self.ref.child("users").child(self.user!.uid).child("twitterData").setValue(["userFirstName": profile.valueForKey("name") as! String!, "userLastName": profile.valueForKey("screen_name") as! String!])
                    self.twitter.titleLabel?.text = "Twitter Added"
                }
            }
        }
        
    }
    
    @IBAction func instagramLogin(sender: AnyObject) {
        let oauthswift = OAuth2Swift(
            consumerKey:    "af9350fa8abd45af978145b4c896359e",
            consumerSecret: "632160631a534b808b2feb4389819acf",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
            // or
            // accessTokenUrl: "https://api.instagram.com/oauth/access_token",
            // responseType:   "code"
        )
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: "Snagged://oauth-callback")!, scope: "likes+comments", state:state, success: {
            credential, response, parameters in
            let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(oauthswift.client.credential.oauth_token)"
            let parameters :Dictionary = Dictionary<String, AnyObject>()
            oauthswift.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    let mainDict = jsonDict.objectForKey("data") as! NSDictionary!
                    self.ref.child("users").child(self.user!.uid).child("instagramData").setValue(["fullName": mainDict?.valueForKey("full_name") as! String!, "profile_picture": mainDict?.valueForKey("profile_picture") as! String!, "username": mainDict?.valueForKey("username") as! String!])
                    self.linkedIn.titleLabel?.text = "Linkedin Added"
                    CommonUtils.sharedUtils.hideProgress()
                }, failure: { error in
                    print(error)
                    CommonUtils.sharedUtils.hideProgress()
            })
            }, failure: { error in
                CommonUtils.sharedUtils.hideProgress()
                print(error.localizedDescription)
        })
    }
    
    @IBAction func linkedInLogin(sender: AnyObject) {
        let oauthswift = OAuth1Swift(
            consumerKey:    "781k8vbvg9p34i",
            consumerSecret: "uDL7nlVXQ2XmB71N",
            requestTokenUrl: "https://api.linkedin.com/uas/oauth/requestToken",
            authorizeUrl:    "https://api.linkedin.com/uas/oauth/authenticate",
            accessTokenUrl:  "https://api.linkedin.com/uas/oauth/accessToken"
        )
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/linkedin")!, success: {
            credential, response, parameters in
            oauthswift.client.get("https://api.linkedin.com/v1/people/~", parameters: [:],
                success: {
                    data, response in
                    print(data)
                    let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    print(dataString)
                    do {
                        let xmlDoc = try AEXMLDocument(xmlData: data)
                        self.ref.child("users").child(self.user!.uid).child("linkedinData").setValue(["userFirstName": xmlDoc.root["first-name"].value!, "userlastName": xmlDoc.root["last-name"].value!, "headline": xmlDoc.root["headline"].value!, "url": xmlDoc.root["site-standard-profile-request"]["url"].value!])
                        self.linkedIn.titleLabel?.text = "Linkedin Added"
                        CommonUtils.sharedUtils.hideProgress()
                    }
                    catch{
                        
                    }
                }, failure: { error in
                    print(error)
            })
            }, failure: { error in
                CommonUtils.sharedUtils.hideProgress()
                print(error.localizedDescription)
        })
    }
}
