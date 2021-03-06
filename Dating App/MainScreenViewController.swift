//
//  ViewController.swift
//  Dating App
//
//  Created by Dustin Allen on 7/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func videoButton(sender: AnyObject) {
        let videoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("VideoViewController") as! VideoViewController!
        self.navigationController?.pushViewController(videoViewController, animated: true)
    }

    @IBAction func interestsFeedButton(sender: AnyObject) {
        let interestMenuTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InterestViewController") as! InterestViewController!
        self.navigationController?.pushViewController(interestMenuTableViewController, animated: true)
    }
    @IBAction func settingsButton(sender: AnyObject) {
        let settingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController!
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
}

