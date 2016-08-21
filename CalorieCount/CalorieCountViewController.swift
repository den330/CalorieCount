//
//  ViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class CalorieCountViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    var managedContext: NSManagedObjectContext!
    var NaviController: UINavigationController?
    var didTip = false
    var pendingFav: Food!
    var recentDay: Day!
    var itemForSelected: ItemConsumed!
    var appdelegate: AppDelegate!
    
    
    @IBOutlet weak var filterHeight: NSLayoutConstraint!
    @IBOutlet weak var filterTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let net = NetworkGrab()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CalorieCountViewController.handleLongPress))
        tableView.addGestureRecognizer(longPress)
        longPress.cancelsTouchesInView = true
        let slideToRight = UISwipeGestureRecognizer(target: self, action: #selector(CalorieCountViewController.handleSwipe))
        tableView.addGestureRecognizer(slideToRight)
        slideToRight.cancelsTouchesInView = true
        tableView.contentInset = UIEdgeInsets(top: commonConstants.topInsets, left: 0, bottom: 0, right: 0)
        let cellNib = UINib(nibName: commonConstants.cellXib, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: commonConstants.cellXib)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().boolForKey("said it") == false{
            let message = "For complete and the most up-to-date manual, click 'Manual' in Fav Tab"
            makeAlert(message, vc: self, title: "Tips")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "said it")
        }
    }
    
    func makeFavAlert(){
        let alert = UIAlertController(title: "Favorite", message: "Add to Favorite", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Add it!", style: .Default, handler: {[unowned self] _ in self.handleFav()}))
        alert.addAction(UIAlertAction(title: "Don't", style: .Default, handler: nil))
        presentViewController(alert,animated: true, completion: nil)
        alert.view.tintColor = UIColor.redColor()
    }
    
    func handleFav(){
        let fetchRequest = NSFetchRequest(entityName: "ItemConsumed")
        fetchRequest.predicate = NSPredicate(format: "isFav==%@", true)
        var results:[ItemConsumed]?
        do{
            results = try managedContext.executeFetchRequest(fetchRequest) as? [ItemConsumed]
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        guard let lst = results else{
            print("Wrong")
            return
        }
        for i in lst{
            if i.id == pendingFav.id{
                return
            }
        }
        let itemEntity = NSEntityDescription.entityForName("ItemConsumed", inManagedObjectContext: managedContext)!
        let favFood = ItemConsumed(entity: itemEntity, insertIntoManagedObjectContext: managedContext)
        favFood.brand = pendingFav.brandContent
        favFood.id = pendingFav.id
        favFood.isFav = true
        favFood.name = pendingFav.foodContent
        favFood.quantity = String(pendingFav.quantity) + " " + pendingFav.unit
        favFood.quantityConsumed = 0
        favFood.totalCalories = 0
        favFood.unitCalories = pendingFav.caloriesCount
        do{
            try managedContext.save()
        }catch{
            print(error)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch net.state{
            case .NotFound, .Searching: return 1
            case .NotSearchedYet: return 1
            case .SearchSuccess(let lst): return lst.count
            case .NoConnection: return 1
            }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commonConstants.cellXib, forIndexPath: indexPath) as! FoodCell
        cell.selectionStyle = .None
        switch net.state{
            case .SearchSuccess(let lst):
                cell.selectionStyle = .Default
                let foodItem = lst[indexPath.row]
                configureCell(cell, foodContent: foodItem.foodContent, caloriesContent: foodItem.caloriesCount, brandContent: foodItem.brandContent,quantityContent: foodItem.quantity,unitContent: foodItem.unit)
                return cell
            case .NotFound:
                configureCell(cell, foodContent: "NA", caloriesContent: 0,brandContent: "NA",quantityContent: nil,unitContent: nil)
            case .NoConnection:
                configureCell(cell, foodContent: "No Connection", caloriesContent: 0, brandContent: "NA", quantityContent: nil, unitContent: nil)
            case .Searching:
                configureCell(cell, foodContent: "Searching", caloriesContent: 0, brandContent: "Searching",quantityContent: nil,unitContent: nil)
            case .NotSearchedYet:
                configureCell(cell, foodContent: "Click Search bar to start search", caloriesContent: 0, brandContent: "", quantityContent: nil,unitContent: nil)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch net.state{
            case .SearchSuccess( _):
                return indexPath
            default: return nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showDetail", sender: indexPath)
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Began {
            let touchPoint = sender.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                if let lst = net.state.get(){
                    pendingFav = lst[indexPath.row]
                    makeFavAlert()
                }
            }
        }
    }
    
    func quickSave(indexPath: NSIndexPath){
        if let lst = net.state.get(){
            let food = lst[indexPath.row]
            save(managedContext, food: food, quantity: 1)
            let hudView: HudView = HudView.hudInView(view, animated: true)
            hudView.text = "1 Unit Saved"
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoodCell
            let storedCal = cell.calorieLabel.text
            cell.calorieLabel.text = "1 Unit Added"
            postNotification()
            let delayInSeconds = 0.6
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds*Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue()){
                hudView.removeFromSuperview()
                cell.calorieLabel.text = storedCal
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer){
        if sender.direction == .Right{
            let slidePoint = sender.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(slidePoint){
                quickSave(indexPath)
            }
        }
    }
    
    



    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail"{
            let detailController = segue.destinationViewController as! DetailViewController
            let index = sender as! NSIndexPath
            if let lst = net.state.get(){
                detailController.foodSelected = lst[index.row]
                detailController.managedContext = managedContext
                detailController.fromMain = true
            }
        }
    }
}

extension CalorieCountViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        let text = searchBar.text!
        let filtertext = filterTextField.text!
        if text != ""{
            net.performSearch(text, filterText: filtertext){
                self.tableView.reloadData()
            }
            tableView.reloadData()
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension CalorieCountViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
            searchBarSearchButtonClicked(searchBar)
            textField.resignFirstResponder()
            return false
    }
}

extension CalorieCountViewController: MFMailComposeViewControllerDelegate{
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






