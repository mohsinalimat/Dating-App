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
    var objects: NSMutableArray! = NSMutableArray()
    
    var tableData: [String] = ["Active Lifestyle", "Nightlife", "Music", "Food", "Travel", "Tech", "Fashion", "Photography", "Automotive", "Local", "Literature", "Religion", "Pets", "Art"]
    var arrImageName: [String] = ["Active Lifestyle", "Nightlife", "Music", "Food", "Travel", "Tech", "Fashion", "Photography", "Automotive", "Local", "Literature", "Religion", "Pets", "Art"]


    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.objects.addObject("Active Lifestyle")
        self.objects.addObject("Nightlife")
        self.objects.addObject("Music")
        self.objects.addObject("Food")
        self.objects.addObject("Travel")
        self.objects.addObject("Tech")
        self.objects.addObject("Fashion")
        self.objects.addObject("Photography")
        self.objects.addObject("Automotive")
        self.objects.addObject("Local")
        self.objects.addObject("Literature")
        self.objects.addObject("Religion")
        self.objects.addObject("Pets")
        self.objects.addObject("Art")
        
        self.tableView.reloadData()

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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.performSegueWithIdentifier("VideoFeed", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "VideoFeed")
        {
            let upcoming: NewViewController = segue.destinationViewController as! NewViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let titleString = self.objects.objectAtIndex(indexPath.row) as? String
            upcoming.titleString = titleString
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }


}

