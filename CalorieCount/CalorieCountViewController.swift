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

class CalorieCountViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,MyAlertControllerDelegate{
    
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
    
    private struct commonConstants{
        static let topInsets:CGFloat = 92
        static let cellXib = "FoodCell"
    }
    
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
            let message = "For complete and the most up-to-date manual, unlock your rotation lock(if not already), and rotate your phone to horizontal(landscape) view with Search bar selected"
            makeAlert(message)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "said it")
        }else if NSUserDefaults.standardUserDefaults().boolForKey("Update Informed") == false{
            let message = "If You Simply Want To Add 1 Unit Of The Item You Choose, Instead Of Tapping, Try 'Slide To The Right'"
            makeAlert(message)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "Update Informed")
        }
    }
    
    func makeAlert(message: String){
        let title = "Tips"
        let alert = MyAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.delegate = self
        alert.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17),NSForegroundColorAttributeName : UIColor.whiteColor()]), forKey: "attributedTitle")
        alert.setValue(NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15),NSForegroundColorAttributeName : UIColor.yellowColor()]), forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Got it", style: .Default, handler: nil))
        let subview = alert.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        alertContentView.backgroundColor = UIColor.darkGrayColor()
        presentViewController(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.greenColor()
    }
    
    func makeFavAlert(){
        let alert = MyAlertController(title: "Favorite", message: "Add to Favorite", preferredStyle: UIAlertControllerStyle.Alert)
        alert.delegate = self
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
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if tabBarController?.selectedIndex != 0 || presentedViewController != nil{return}
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        switch newCollection.verticalSizeClass{
        case .Compact:
            searchBar.resignFirstResponder()
            filterTextField.resignFirstResponder()
            showLandscapeViewWithCoordinator(coordinator,thisController: self)
        case .Regular, .Unspecified:
            hideLandscapeViewWithCoordinator(coordinator, thisController: self)
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
            let dayEntity = NSEntityDescription.entityForName("Day", inManagedObjectContext: managedContext)
            let itemEntity = NSEntityDescription.entityForName("ItemConsumed", inManagedObjectContext: managedContext)
            let results = try! managedContext.executeFetchRequest(dayFetch) as! [Day]
            if sameDay(results,day: NSDate()){
                recentDay = results.first!
            }else{
                recentDay = Day(entity: dayEntity!, insertIntoManagedObjectContext: managedContext)
            }
            let items = recentDay.items.mutableCopy() as! NSMutableOrderedSet
            var existed: Bool = false
            for i in items{
                let singleItem = i as! ItemConsumed
                if singleItem.id == food.id{
                    existed = true
                    singleItem.quantityConsumed = singleItem.quantityConsumed + 1
                    let newAddedCalories = food.caloriesCount * Double(1)
                    singleItem.totalCalories = Double(singleItem.totalCalories) + newAddedCalories
                    break
                }
            }
            if !existed{
                itemForSelected = ItemConsumed(entity: itemEntity!, insertIntoManagedObjectContext: managedContext)
                itemForSelected.name = food.foodContent
                itemForSelected.unitCalories = food.caloriesCount
                itemForSelected.totalCalories = Double(1) * Double(itemForSelected.unitCalories)
                itemForSelected.quantity = String(food.quantity) + " " + food.unit
                itemForSelected.brand = food.brandContent
                itemForSelected.id = food.id
                itemForSelected.quantityConsumed = 1
                items.addObject(itemForSelected)
            }
            recentDay.items = items.copy() as! NSOrderedSet
            recentDay.currentDate = NSDate()
            try! managedContext.save()
            let hudView: HudView = HudView.hudInView(view, animated: true)
            hudView.text = "1 Unit Saved"
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoodCell
            let storedCal = cell.calorieLabel.text
            cell.calorieLabel.text = "1 Added"
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






