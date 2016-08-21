//
//  DIYListViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/8/21.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData

class DIYListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController!
    let fetchRequest = NSFetchRequest(entityName: "ItemConsumed")
    var managedContext: NSManagedObjectContext!
    var itemForSelected: ItemConsumed!
    var recentDay: Day!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let cellNib = UINib(nibName: commonConstants.cellXib, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: commonConstants.cellXib)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        let slideToRight = UISwipeGestureRecognizer(target: self, action: #selector(DIYListViewController.handleSwipe))
        tableView.addGestureRecognizer(slideToRight)
        slideToRight.cancelsTouchesInView = true
        let sortDescriptor = NSSortDescriptor(key: "unitCalories", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "isMy==%@", true)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func handleSwipe(Swipe: UISwipeGestureRecognizer){
        if Swipe.direction == .Right{
            let touchPoint = Swipe.locationInView(tableView)
            let indexPath = tableView.indexPathForRowAtPoint(touchPoint)
            quickSave(indexPath)
        }
    }
    
    func quickSave(indexPath: NSIndexPath?){
        if let indexPath = indexPath{
            let item = fetchedResultsController.objectAtIndexPath(indexPath) as! ItemConsumed
            save(managedContext, food: item, quantity: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoodCell
            let calorieText = cell.calorieLabel.text
            cell.calorieLabel.text = "1 Unit Added"
            postNotification()
            let hudView: HudView = HudView.hudInView(view, animated: true)
            hudView.text = "1 Unit Saved"
            let delayInSeconds = 0.6
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds*Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue()){
                cell.calorieLabel.text = calorieText
                hudView.removeFromSuperview()
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        let rowNum = sectionInfo.numberOfObjects
        return rowNum
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commonConstants.cellXib, forIndexPath: indexPath) as! FoodCell
        let item = fetchedResultsController.objectAtIndexPath(indexPath) as! ItemConsumed
        cell.brandLabel.text = item.brand
        cell.calorieLabel.text = String(item.unitCalories) + " " + "Cal"
        cell.foodLabel.text = item.name
        cell.quantityLabel.text = item.quantity
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = fetchedResultsController.objectAtIndexPath(indexPath) as! ItemConsumed
        performSegueWithIdentifier("presentPopUp", sender: item)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            let item = fetchedResultsController.objectAtIndexPath(indexPath) as! ItemConsumed
            managedContext.deleteObject(item)
        }
        do{
            try managedContext.save()
        }catch let error as NSError{
            print("Could not save delete: \(error)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAddEntry"{
            let desCon = segue.destinationViewController as! EntryViewController
            desCon.managedContext = managedContext
        }else if segue.identifier == "presentPopUp"{
            let item = sender as! ItemConsumed
            let DestController = segue.destinationViewController as! DetailViewController
            DestController.itemCon = item
            DestController.managedContext = managedContext
        }
    }
    
    

    
}

extension DIYListViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake{
            if motion == .MotionShake{
                let alert = UIAlertController(title: "Delete", message: "Delete All DIY?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {[unowned self] _ in self.handleMotion()}))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                presentViewController(alert,animated: true, completion: nil)
                alert.view.tintColor = UIColor.redColor()
            }
        }
    }
    
    func handleMotion(){
        let objects = fetchedResultsController.fetchedObjects as! [ItemConsumed]
        for object in objects{
            managedContext.deleteObject(object)
        }
        do{
            try managedContext.save()
        }catch let error as NSError{
            print("Could not save delete: \(error)")
        }
    }
}





