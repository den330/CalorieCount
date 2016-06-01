//
//  DailyConsumeTableViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/15.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DailyConsumeTableViewController: UITableViewController{
    var day: Day!
    var items: NSOrderedSet?
    var managedContext: NSManagedObjectContext!
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = day.items
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        navigationItem.title = dateFormatter.stringFromDate(day.currentDate!)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            let foodToRemove = day.items![indexPath.row] as! ItemConsumed
            managedContext.deleteObject(foodToRemove)
            
            if day.items!.count == 1{
                managedContext.deleteObject(day)
                navigationController?.popViewControllerAnimated(true)
            }
            
            do{
                try managedContext.save()
            }catch let error as NSError{
                print("Could not save delete: \(error)")
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    
    @IBAction func back(){
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath)
        let contentLabel = cell.viewWithTag(1000) as! UILabel
        let caloriesLabel = cell.viewWithTag(1002) as! UILabel
        let quantityLabel = cell.viewWithTag(1001) as! UILabel
        let brandLabel = cell.viewWithTag(1003) as! UILabel
        let unitQuantityLabel = cell.viewWithTag(1004) as! UILabel
        let item = day.items![indexPath.row] as! ItemConsumed
        contentLabel.text = item.name
        caloriesLabel.text = "Total Calories: " + String(format: "%.2f", Double(item.totalCalories!))
        quantityLabel.text = "Quantity Consumed: " + String(item.quantityConsumed!)
        brandLabel.text = "Brand: " + item.brand!
        unitQuantityLabel.text = "Unit: " + item.quantity!
        return cell
    }
    
    @IBAction func handleSwipe(recognizer:UISwipeGestureRecognizer) {
        back()
    }
    
    
    
}
