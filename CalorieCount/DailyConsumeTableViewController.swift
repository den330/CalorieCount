//
//  DailyConsumeTableViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/15.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import UIKit

class DailyConsumeTableViewController: UITableViewController{
    var day: Day!
    var items: NSOrderedSet?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = day.items
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    
    @IBAction func back(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath)
        let contentLabel = cell.viewWithTag(1000) as! UILabel
        let caloriesLabel = cell.viewWithTag(1002) as! UILabel
        let quantityLabel = cell.viewWithTag(1001) as! UILabel
        let item = day.items![indexPath.row] as! ItemConsumed
        contentLabel.text = item.name
        caloriesLabel.text = "Total Calories: " + String(item.totalCalories!)
        quantityLabel.text = "Quantity Consumed: " + String(item.quantityConsumed!)
        return cell
    }
}
