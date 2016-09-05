//
//  FavViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/6/12.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class FavViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController!
    let fetchRequest = NSFetchRequest(entityName: "ItemConsumed")
    var managedContext: NSManagedObjectContext!
    var itemForSelected: ItemConsumed!
    var recentDay: Day!
    let searchController = UISearchController(searchResultsController: nil)
    var filteredItem = [ItemConsumed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.delegate = self
        tableView.dataSource = self
        let cellNib = UINib(nibName: commonConstants.cellXib, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: commonConstants.cellXib)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        let slideToRight = UISwipeGestureRecognizer(target: self, action: #selector(FavViewController.handleSwipe))
        tableView.addGestureRecognizer(slideToRight)
        slideToRight.cancelsTouchesInView = true
        let sortDescriptor = NSSortDescriptor(key: "unitCalories", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "isFav==%@", true)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != ""{
            return filteredItem.count
        }
        let sectionInfo = fetchedResultsController.sections![section]
        let rowNum = sectionInfo.numberOfObjects
        return rowNum
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
            let item: ItemConsumed
            if searchController.active && searchController.searchBar.text != ""{
                item = filteredItem[indexPath.row]
            }else{
                item = fetchedResultsController.objectAtIndexPath(indexPath) as! ItemConsumed
            }
            save(managedContext, food: item, quantity: 1)
            let hudView: HudView = HudView.hudInView(view, animated: true)
            hudView.text = "1 Unit Saved"
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoodCell
            let calorieText = cell.calorieLabel.text
            cell.calorieLabel.text = "1 Unit Added"
            postNotification()
            let delayInSeconds = 0.6
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds*Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue()){
                cell.calorieLabel.text = calorieText
                hudView.removeFromSuperview()
                self.view.userInteractionEnabled = true
            }
        }
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commonConstants.cellXib, forIndexPath: indexPath) as! FoodCell
        let item:ItemConsumed
        if searchController.active && searchController.searchBar.text != ""{
            item = filteredItem[indexPath.row]
        }else{
            item = fetchedResultsController.objectAtIndexPath(indexPath) as! ItemConsumed
        }
        cell.brandLabel.text = item.brand
        cell.calorieLabel.text = String(item.unitCalories) + " " + "Cal"
        cell.foodLabel.text = item.name
        cell.quantityLabel.text = item.quantity
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            let item: ItemConsumed
            if searchController.active  && searchController.searchBar.text != ""{
                print("haha")
                item = filteredItem[indexPath.row]
                managedContext.deleteObject(item)
                try! managedContext.save()
                filterItemForSearchText(searchController.searchBar.text!)
            }else{
                item = fetchedResultsController.objectAtIndexPath(indexPath) as! ItemConsumed
                managedContext.deleteObject(item)
                try! managedContext.save()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController.active  && searchController.searchBar.text != ""{
            performSegueWithIdentifier("showPop", sender: filteredItem[indexPath.row])
        }else{
            performSegueWithIdentifier("showPop", sender: fetchedResultsController.objectAtIndexPath(indexPath) as! ItemConsumed)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPop"{
            let item = sender as! ItemConsumed
            let DestController = segue.destinationViewController as! DetailViewController
            DestController.itemCon = item
            DestController.managedContext = managedContext
        }
    }
}



extension FavViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if searchController.active && searchController.searchBar.text != ""{
            return
        }
        switch type{
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        default: break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake{
            let alert: UIAlertController
            if searchController.active && searchController.searchBar.text != ""{
                let text = searchController.searchBar.text!
                alert = UIAlertController(title: "Delete", message: "Delete All Fav Containing \(text)?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {[unowned self] _ in self.handleMotion()}))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                presentViewController(alert,animated: true, completion: nil)
                alert.view.tintColor = UIColor.redColor()
            }else{
                alert = UIAlertController(title: "Delete", message: "Delete All Fav?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {[unowned self] _ in self.handleMotion()}))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                presentViewController(alert,animated: true, completion: nil)
                alert.view.tintColor = UIColor.redColor()
            }
        }
    }
    
    func handleMotion(){
        let objects: [ItemConsumed]
        if searchController.active && searchController.searchBar.text != ""{
            objects = filteredItem
        }else{
            objects = fetchedResultsController.fetchedObjects as! [ItemConsumed]
        }
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

extension FavViewController: UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterItemForSearchText(searchController.searchBar.text!)
    }
    
    func filterItemForSearchText(searchText: String){
        let list = fetchedResultsController.fetchedObjects as! [ItemConsumed]
        filteredItem = list.filter{ item in return item.foodProContent.lowercaseString.containsString(searchText.lowercaseString)}
        tableView.reloadData()
    }
}



