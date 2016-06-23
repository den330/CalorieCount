//
//  RecordTableViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/17.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData
import MessageUI


class RecordTableViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController!
    let fetchRequest = NSFetchRequest(entityName: "Day")
    var managedContext: NSManagedObjectContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60
        let sortDescriptor = NSSortDescriptor(key: "currentDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print("Error: \(error.localizedDescription)")
        }
        tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var i = 0
        while i < 2{
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath){
                let dateLabel =  cell.viewWithTag(1000) as! UILabel
                let day = fetchedResultsController.objectAtIndexPath(indexPath) as! Day
                if sameDay([day], day: NSDate()){
                    dateLabel.text = "Today"
                }else{
                    dateLabel.text = dateFormatter.stringFromDate(day.currentDate!)
                }
            }
            i += 1
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        let rowNum = sectionInfo.numberOfObjects
        return rowNum
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recordCell", forIndexPath: indexPath)
        let day = fetchedResultsController.objectAtIndexPath(indexPath) as! Day
        configureCell(cell, day: day)
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            let day = fetchedResultsController.objectAtIndexPath(indexPath) as! Day
            for item in day.items!{
                let i = item as! ItemConsumed
                managedContext.deleteObject(i)
            }
            managedContext.deleteObject(day)
        }
        
            do{
                try managedContext.save()
            }catch let error as NSError{
                print("Could not save delete: \(error)")
            }
    }
    
    
    func configureCell(cell: UITableViewCell, day: Day){
        let items = day.items!
        var totalCalories = 0.0
        for i in items{
            let item = i as! ItemConsumed
            totalCalories += Double(item.totalCalories)
        }
        let dateLabel =  cell.viewWithTag(1000) as! UILabel
        let caloriesLabel = cell.viewWithTag(1001) as! UILabel
        let date = dateFormatter.stringFromDate(day.currentDate!)
        dateLabel.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        caloriesLabel.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        dateLabel.text = date
        caloriesLabel.text = "Total: " + String(format: "%.2f", Double(totalCalories)) + " Cal"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showthatday", sender: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showthatday"{
            let index = sender as! NSIndexPath
            let dayController = segue.destinationViewController as! DailyConsumeTableViewController
            dayController.day = fetchedResultsController.objectAtIndexPath(index) as! Day
            dayController.managedContext = managedContext
        }
    }
}

extension RecordTableViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            let day = fetchedResultsController.objectAtIndexPath(indexPath!) as! Day
            configureCell(cell!, day: day)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake{
            let alert = UIAlertController(title: "Delete", message: "Delete All Records?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {_ in self.handleMotion()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            presentViewController(alert,animated: true, completion: nil)
            alert.view.tintColor = UIColor.redColor()
        }
    }
    
    func handleMotion(){
        let days = fetchedResultsController.fetchedObjects as! [Day]
        for day in days{
            for item in day.items!{
                managedContext.deleteObject(item as! ItemConsumed)
            }
            managedContext.deleteObject(day)
            do{
                try managedContext.save()
            }catch let error as NSError{
                print("Could not save delete: \(error)")
            }
        }
    }
}

extension RecordTableViewController: UITabBarControllerDelegate{
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        navigationController?.popViewControllerAnimated(true)
    }
}




