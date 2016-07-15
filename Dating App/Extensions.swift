//
//  Extensions.swift
//  Connect App
//
//  Created by Dustin Allen on 7/10/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import EZSwipeController


extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.sharedApplication()
        for url in urls {
            if application.canOpenURL(NSURL(string: url)!) {
                application.openURL(NSURL(string: url)!)
                return
            }
        }
    }
}

class MySwipeVC: EZSwipeController {
    override func setupView() {
        datasource = self
    }
}

extension MySwipeVC: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        let redVC = UIViewController()
        redVC.view.backgroundColor = UIColor.redColor()
        
        let blueVC = UIViewController()
        blueVC.view.backgroundColor = UIColor.blueColor()
        
        let greenVC = UIViewController()
        greenVC.view.backgroundColor = UIColor.greenColor()
        
        return [redVC, blueVC, greenVC]
    }
}