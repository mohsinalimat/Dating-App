//
//  MessageViewController.swift
//  Pods
//
//  Created by Dustin Allen on 7/17/16.
//
//

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@objc(MessageViewController)
class MessageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleLogTokenTouch(sender: UIButton) {
        // [START get_iid_token]
        let token = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(token!)")
        // [END get_iid_token]
    }
    
    @IBAction func handleSubscribeTouch(sender: UIButton) {
        // [START subscribe_topic]
        FIRMessaging.messaging().subscribeToTopic("/topics/news")
        print("Subscribed to news topic")
        // [END subscribe_topic]
    }
}