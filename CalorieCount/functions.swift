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
let DoneSearchingNotification = "Done Searching"

var landscapeViewController: LandscapeViewController?

func postNotification(){
    NSNotificationCenter.defaultCenter().postNotificationName(IndexUpdateNotification, object: nil)
}

func postDoneSearching(){
    NSNotificationCenter.defaultCenter().postNotificationName(DoneSearchingNotification,object: nil)
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



