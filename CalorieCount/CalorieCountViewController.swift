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
    let transition = DetailAnimationController()
    var didTip = false
    var pendingFav: Food!
    
    @IBOutlet weak var filterTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let net = NetworkGrab()
    
    private struct commonConstants{
        static let rowHeight:CGFloat = 170
        static let topInsets:CGFloat = 92
        static let cellXib = "FoodCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(CalorieCountViewController.handleLongPress))
        tableView.addGestureRecognizer(longPress)
        longPress.cancelsTouchesInView = true
        tableView.contentInset = UIEdgeInsets(top: commonConstants.topInsets, left: 0, bottom: 0, right: 0)
        let cellNib = UINib(nibName: commonConstants.cellXib, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: commonConstants.cellXib)
        tableView.rowHeight = commonConstants.rowHeight
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var message: String
        if didTip == false{
            if NSUserDefaults.standardUserDefaults().boolForKey("knowDelete"){
                switch NSUserDefaults.standardUserDefaults().valueForKey("tips") as? Int{
                case nil:
                    message = "Idea for a new feature? SHAKE your phone and let me know!"
                    makeAlert(message)
                    NSUserDefaults.standardUserDefaults().setValue(1, forKey: "tips")
                case 1?:
                    message = "For an item you frequently search, LONG PRESS it and add it to Fav, so next time" +
                    " you can add it directly from Fav tab without searching!"
                    makeAlert(message)
                    NSUserDefaults.standardUserDefaults().setValue(2, forKey: "tips")
                default: break
                }
            }
            switch NSUserDefaults.standardUserDefaults().objectForKey("knowDelete"){
                case nil:
                    message = "You can delete your calorie record(single item or entire day) by swiping (to the left)"
                    makeAlert(message)
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "knowDelete")
                default: break
            }
            didTip = true
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
        alert.addAction(UIAlertAction(title: "Add it!", style: .Default, handler: {_ in self.handleFav()}))
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
        favFood.id = pendingFav.id!
        favFood.isFav = true
        favFood.name = pendingFav.foodContent
        if let quantity = pendingFav.quantity, unit = pendingFav.unit{
            favFood.quantity = String(quantity) + " " + unit
        }else{
            favFood.quantity = "NA"
        }
        favFood.quantityConsumed = 0
        favFood.totalCalories = 0
        favFood.unitCalories = pendingFav.caloriesCount!
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
                configureCell(cell, foodContent: foodItem.foodContent!, caloriesContent: foodItem.caloriesCount!, brandContent: foodItem.brandContent!,quantityContent: foodItem.quantity,unitContent: foodItem.unit)
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
        transition.presenting = true
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
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail"{
            let detailController = segue.destinationViewController as! DetailViewController
            detailController.transitioningDelegate = self
            let index = sender as! NSIndexPath
            if let lst = net.state.get(){
                detailController.foodSelected = lst[index.row]
                detailController.managedContext = managedContext
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


extension CalorieCountViewController: UIViewControllerTransitioningDelegate{
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
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






