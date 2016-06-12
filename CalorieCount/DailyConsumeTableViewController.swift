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
import MessageUI

class DailyConsumeTableViewController: UITableViewController{
    var day: Day!
    var items: NSOrderedSet?
    var managedContext: NSManagedObjectContext!
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = day.items
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        navigationItem.title = "on " + dateFormatter.stringFromDate(day.currentDate!)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            let foodToRemove = day.items![indexPath.row] as! ItemConsumed
            managedContext.deleteObject(foodToRemove)
            
            if day.items!.count == 1{
                managedContext.deleteObject(day)
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
        caloriesLabel.text = "Total Calories: " + String(format: "%.2f", Double(item.totalCalories)) + " Cal"
        quantityLabel.text = "Quantity Consumed: " + String(item.quantityConsumed)
        brandLabel.text = "Brand: " + item.brand!
        if let quantity = item.quantity{
            unitQuantityLabel.text = "Unit: " + quantity
        }else{
            unitQuantityLabel.text = "Unit: NA"
        }
        return cell
    }
}

extension DailyConsumeTableViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake{
            showEmail()
        }
    }
    
    func showEmail(){
        if presentedViewController != nil{
            dismissViewControllerAnimated(true,completion: nil)
        }
        makeEmail()
    }
    
    func makeEmail(){
        if MFMailComposeViewController.canSendMail(){
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject(NSLocalizedString("App Suggestion", comment: "Email Sub"))
            controller.setToRecipients(["yaxinyuan0910@gmail.com"])
            presentViewController(controller, animated: true, completion: nil)
        }
    }
}



