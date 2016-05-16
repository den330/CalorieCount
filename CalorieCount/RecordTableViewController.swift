//
//  RecordTableViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/17.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData


class RecordTableViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController!
    let fetchRequest = NSFetchRequest(entityName: "Day")
    var managedContext: NSManagedObjectContext!
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .MediumStyle
        let sortDescriptor = NSSortDescriptor(key: "currentDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print("Error: \(error.localizedDescription)")
        }
    }
    
//    @IBAction func itemDidEdited(segue: UIStoryboardSegue){
//        tableView.reloadData()
//    }
    

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
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
            totalCalories += Double(item.totalCalories!)
        }
        let dateLabel =  cell.viewWithTag(1000) as! UILabel
        let caloriesLabel = cell.viewWithTag(1001) as! UILabel
        let today = dateFormatter.stringFromDate(day.currentDate!)
        dateLabel.text = today
        caloriesLabel.text = "Total Calories Consumed: " + String(totalCalories) + " kCal"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showthatday", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showthatday"{
            let index = sender as! NSIndexPath
            let naviController = segue.destinationViewController as! UINavigationController
            let dayController = naviController.topViewController as! DailyConsumeTableViewController
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
}
