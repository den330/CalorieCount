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
        if !NSUserDefaults.standardUserDefaults().boolForKey("DIYAgain"){
            let message = "Can’t Find What You Want From Our Server Yet You Did Learn the Calorie Amount Of a Certain Item From Some Other Source? Then Build An Item For Yourself So That You Can Add It To Your Daily Record Directly From This Tab"
            makeAlert(message, vc: self.parentViewController!, title: "Tips")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "DIYAgain")
        }
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
    
    
    @IBAction func addEntry(sender: UIBarButtonItem) {
        let title = "DIY"
        let message = "Add Your Item Here"
        let color = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        let ac = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        ac.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(25),NSForegroundColorAttributeName : color]), forKey: "attributedTitle")
        ac.setValue(NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(20),NSForegroundColorAttributeName : color]), forKey: "attributedMessage")
        ac.addTextFieldWithConfigurationHandler({textfield in
        textfield.placeholder = "Calorie Amount"} )
        ac.addTextFieldWithConfigurationHandler({textfield in
            textfield.placeholder = "Brand(Optional)"} )
        ac.addTextFieldWithConfigurationHandler({textfield in
            textfield.placeholder = "Unit(Optional)"} )
        ac.addTextFieldWithConfigurationHandler({textfield in
            textfield.placeholder = "Name(Optional)"} )
        let action = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { _ in
            if !isValidNumber(ac.textFields![0].text!){
                makeAlert("Invalid Input As Calorie Amount", vc: self, title: "Invalid Input")
            }else{
                makeAlertNoButton("Successfully Saved", vc: self, title: "Success")
                dismissPopup(self, time: 1.0)
                let brandField = ac.textFields![1]
                let nameField = ac.textFields![3]
                let unitField = ac.textFields![2]
                let calorieField = ac.textFields![0]
                self.saveEntry(brandField, nameField: nameField, unitField: unitField, calorieField: calorieField)
            }
        })
        ac.addAction(action)
        let action2 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        ac.addAction(action2)
        presentViewController(ac, animated: true, completion: nil)
        ac.view.tintColor = color
    }
    
    func doSth(){
        print("haha")
    }
    
    func saveEntry(brandField: UITextField, nameField: UITextField, unitField: UITextField, calorieField: UITextField){
        let itemEntity = NSEntityDescription.entityForName("ItemConsumed", inManagedObjectContext: managedContext)
        let entry = ItemConsumed(entity: itemEntity!, insertIntoManagedObjectContext: managedContext)
        entry.isMy = true
        entry.id = String(NSUserDefaults.standardUserDefaults().integerForKey("DIYID") + 1)
        NSUserDefaults.standardUserDefaults().setInteger(Int(entry.id)!, forKey: "DIYID")
        if brandField.text! != ""{
            entry.brand = brandField.text!
        }
        if nameField.text! != ""{
            entry.name = nameField.text!
        }
        entry.unitCalories = Double(calorieField.text!)!
        if unitField.text! != ""{
            entry.quantity = unitField.text!
        }
        try! managedContext.save()
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
        if segue.identifier == "presentPopUp"{
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
            let alert = UIAlertController(title: "Delete", message: "Delete All DIY?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {[unowned self] _ in self.handleMotion()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            presentViewController(alert,animated: true, completion: nil)
            alert.view.tintColor = UIColor.redColor()
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





