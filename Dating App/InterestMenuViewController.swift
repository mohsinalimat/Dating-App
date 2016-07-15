//
//  InterestMenuViewController.swift
//  Dating App
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

class InterestMenuTableViewController: UITableViewController {
    
    var maxRows = 10
    var maxSections = 8
    
    //MARK: Table Data Sources
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return maxSections
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maxRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = String(format: "Section %i, Row %i",indexPath.section,indexPath.row)
        cell.backgroundColor = cellColorForIndex(indexPath)
        return cell
        
    }
    
    //MARK: Instance Methods
    func cellColorForIndex(indexPath:NSIndexPath) -> UIColor{
        //cast row and section to CGFloat
        let row = CGFloat(indexPath.row)
        let section = CGFloat(indexPath.section)
        //compute row as hue and section as saturation
        let saturation  = 1.0 - row / CGFloat(maxRows)
        let hue =  section / CGFloat(maxSections)
        return UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
    }
}