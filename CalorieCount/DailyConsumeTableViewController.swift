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
        navigationItem.title = "on " + dateFormatter.string(from: day.currentDate)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            let foodToRemove = day.items[(indexPath as NSIndexPath).row] as! ItemConsumed
            managedContext.delete(foodToRemove)
            
            if day.items.count == 1{
                managedContext.delete(day)
            }
            
            do{
                try managedContext.save()
                postNotification()
            }catch let error as NSError{
                print("Could not save delete: \(error)")
            }
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        let contentLabel = cell.viewWithTag(1000) as! UILabel
        let caloriesLabel = cell.viewWithTag(1002) as! UILabel
        let quantityLabel = cell.viewWithTag(1001) as! UILabel
        let brandLabel = cell.viewWithTag(1003) as! UILabel
        let unitQuantityLabel = cell.viewWithTag(1004) as! UILabel
        let item = day.items[(indexPath as NSIndexPath).row] as! ItemConsumed
        contentLabel.text = item.name
        caloriesLabel.text = "Total Calories: " + String(format: "%.2f", Double(item.totalCalories)) + " Cal"
        quantityLabel.text = "Quantity Consumed: " + String(item.quantityConsumed)
        brandLabel.text = "Brand: " + item.brand
        unitQuantityLabel.text = "Unit: " + item.quantity
        return cell
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake{
            let alert = UIAlertController(title: "Delete", message: "Delete All Records On This Day?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {[unowned self] _ in self.handleMotion()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert,animated: true, completion: nil)
            alert.view.tintColor = UIColor.red
        }
    }
    
    func handleMotion(){
        for i in day.items{
            managedContext.delete(i as! ItemConsumed)
        }
        managedContext.delete(day)
       
        do{
            try managedContext.save()
            postNotification()
        }catch let error as NSError{
            print("Could not save delete: \(error)")
        }
        tableView.reloadData()
    }
}





