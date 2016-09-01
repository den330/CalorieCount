//
//  functions.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/31.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import CoreData
import MessageUI
import UIKit

let IndexUpdateNotification = "Update Notification"


var landscapeViewController: LandscapeViewController?


protocol FoodProtocol {
    var foodProId: String {get}
    var foodProCalorie: Double {get}
    var foodProContent: String {get}
    var foodProBrand: String {get}
    var foodProUnit: String{get}
}

func save<T:FoodProtocol>(thisManagedContext: NSManagedObjectContext, food: T, quantity: Int){
    var recentDay: Day!
    var itemForSelected: ItemConsumed!
    let dayEntity = NSEntityDescription.entityForName("Day", inManagedObjectContext: thisManagedContext)
    let itemEntity = NSEntityDescription.entityForName("ItemConsumed", inManagedObjectContext: thisManagedContext)
    let results = try! thisManagedContext.executeFetchRequest(dayFetch) as! [Day]
    if sameDay(results,day: NSDate()){
        recentDay = results.first!
    }else{
        recentDay = Day(entity: dayEntity!, insertIntoManagedObjectContext: thisManagedContext)
    }
    let items = recentDay.items.mutableCopy() as! NSMutableOrderedSet
    var existed: Bool = false
    for i in items{
        let singleItem = i as! ItemConsumed
        if singleItem.id == food.foodProId{
            existed = true
            singleItem.quantityConsumed = singleItem.quantityConsumed + quantity
            let newAddedCalories = food.foodProCalorie * Double(quantity)
            singleItem.totalCalories = singleItem.totalCalories + newAddedCalories
            break
        }
    }
    if !existed{
        itemForSelected = ItemConsumed(entity: itemEntity!, insertIntoManagedObjectContext: thisManagedContext)
        itemForSelected.quantityConsumed = Int32(quantity)
        itemForSelected.name = food.foodProContent
        itemForSelected.unitCalories = food.foodProCalorie
        itemForSelected.totalCalories = Double((itemForSelected.quantityConsumed)) * Double((itemForSelected.unitCalories))
        itemForSelected.quantity = food.foodProUnit
        itemForSelected.brand = food.foodProBrand
        itemForSelected.id = food.foodProId
        items.addObject(itemForSelected)
    }
    recentDay.items = items.copy() as! NSOrderedSet
    recentDay.currentDate = NSDate()
    try! thisManagedContext.save()
}


func postNotification(){
    NSNotificationCenter.defaultCenter().postNotificationName(IndexUpdateNotification, object: nil)
}

var dateFormatter: NSDateFormatter = {
    var dateformatter = NSDateFormatter()
    dateformatter.dateFormat = "MMM d, yyyy"
    return dateformatter
}()

func configureCell(cell: FoodCell, foodContent: String, caloriesContent: Double, brandContent: String, quantityContent: Double?,unitContent: String?){
    cell.foodLabel.text = foodContent
    cell.calorieLabel.text = String(caloriesContent) + " Cal"
    cell.brandLabel.text = brandContent
    cell.quantityLabel.text = (quantityContent == nil) ? "NA" : String(quantityContent!) + " " + unitContent!
}

func sameDay(dayLst:[Day],day: NSDate) -> Bool{
    if dayLst.count == 0{
        return false
    }
    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
    let recentDate = dayLst.first?.currentDate
    return calendar!.isDate(day, inSameDayAsDate: recentDate!)
}

let dayFetch: NSFetchRequest = {
    let Fetch = NSFetchRequest(entityName: "Day")
    let sort = NSSortDescriptor(key: "currentDate", ascending: false)
    Fetch.sortDescriptors = [sort]
    Fetch.fetchLimit = 1
    return Fetch
}()

let daysFetch: NSFetchRequest = {
    let Fetch = NSFetchRequest(entityName: "Day")
    let sort = NSSortDescriptor(key: "currentDate", ascending: false)
    Fetch.sortDescriptors = [sort]
    return Fetch
}()

let itemConsumedFetch: NSFetchRequest = {
    let Fetch = NSFetchRequest(entityName: "ItemConsumed")
    let sort = NSSortDescriptor(key: "unitCalories", ascending: true)
    Fetch.sortDescriptors = [sort]
    return Fetch
}()

func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator, thisController: UIViewController){
    if landscapeViewController != nil {return}
    thisController.tabBarController?.tabBar.hidden = true
    if thisController.presentedViewController != nil{
        thisController.dismissViewControllerAnimated(true, completion: nil)
    }
    landscapeViewController = thisController.storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as?LandscapeViewController
    if let controller = landscapeViewController{
        controller.view.frame = thisController.view.bounds
        thisController.view.addSubview(controller.view)
        thisController.addChildViewController(controller)
        controller.didMoveToParentViewController(thisController)
    }
}

func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator, thisController: UIViewController){
    if let controller = landscapeViewController{
        thisController.tabBarController?.tabBar.hidden = false
        controller.willMoveToParentViewController(nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        landscapeViewController = nil
    }
}

struct commonConstants{
    static let cellXib = "FoodCell"
    static let topInsets:CGFloat = 92
}

func isValidNumber(str:String) -> Bool{
    if str.isEmpty {
        return false
    }
    let newChar = NSCharacterSet(charactersInString: str)
    let boolValid = NSCharacterSet.decimalDigitCharacterSet().isSupersetOfSet(newChar)
    if boolValid{
        return true
    }else{
        let lst = str.componentsSeparatedByString(".")
        let newStr = lst.joinWithSeparator("")
        let currentChar = NSCharacterSet(charactersInString: newStr)
        if lst.count == 2 && !lst.contains("") && NSCharacterSet.decimalDigitCharacterSet().isSupersetOfSet(currentChar){
            return true
        }
        return false
    }
}

func makeAlert(message: String, vc: UIViewController, title: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17),NSForegroundColorAttributeName : UIColor.whiteColor()]), forKey: "attributedTitle")
    alert.setValue(NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15),NSForegroundColorAttributeName : UIColor.whiteColor()]), forKey: "attributedMessage")
    alert.addAction(UIAlertAction(title: "Got it", style: .Default, handler: nil))
    let subview = alert.view.subviews.first! as UIView
    let alertContentView = subview.subviews.first! as UIView
    alertContentView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    vc.presentViewController(alert, animated: true, completion: nil)
    alert.view.tintColor = UIColor.greenColor()
}

func makeAlertNoButton(message: String, vc: UIViewController, title: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17),NSForegroundColorAttributeName : UIColor.whiteColor()]), forKey: "attributedTitle")
    alert.setValue(NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15),NSForegroundColorAttributeName : UIColor.whiteColor()]), forKey: "attributedMessage")
    let subview = alert.view.subviews.first! as UIView
    let alertContentView = subview.subviews.first! as UIView
    alertContentView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    vc.presentViewController(alert, animated: true, completion: nil)
    alert.view.tintColor = UIColor.greenColor()
}

func dismissPopup(vc: UIViewController, time: Double){
    let delayInSeconds = time
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds*Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue()){
        vc.dismissViewControllerAnimated(true, completion: nil)
    }
}



