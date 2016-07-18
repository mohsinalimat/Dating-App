//
//  InterestViewController.swift
//  SimpleTable
//
//  Dustin Allen 7/16/16.
//  Copyright (c) 2016 Harloch. All rights reserved.
//



import UIKit

class InterestViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var tableData: [String] = ["Active Lifestyle", "Nightlife", "Music", "Food", "Travel", "Tech", "Fashion", "Photography", "Automotive", "Local", "Literature", "Religion", "Pets", "Art"]
    var arrImageName: [String] = ["Active Lifestyle", "Nightlife", "Music", "Food", "Travel", "Tech", "Fashion", "Photography", "Automotive", "Local", "Literature", "Religion", "Pets", "Art"]


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.tableData.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell:CustomTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("CustomTableViewCell") as! CustomTableViewCell
        
        cell.imageVW.image = UIImage(named:self.arrImageName[indexPath.row])
        
        cell.lblName.text = self.tableData[indexPath.row]
        
        return cell
    }

 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

