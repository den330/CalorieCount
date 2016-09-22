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

func save<T:FoodProtocol>(_ thisManagedContext: NSManagedObjectContext, food: T, quantity: Int){
    var recentDay: Day!
    var itemForSelected: ItemConsumed!
    let dayEntity = NSEntityDescription.entity(forEntityName: "Day", in: thisManagedContext)
    let itemEntity = NSEntityDescription.entity(forEntityName: "ItemConsumed", in: thisManagedContext)
    let results = try! thisManagedContext.fetch(dayFetch) as! [Day]
    if sameDay(results,day: Date()){
        recentDay = results.first!
    }else{
        recentDay = Day(entity: dayEntity!, insertInto: thisManagedContext)
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
        itemForSelected = ItemConsumed(entity: itemEntity!, insertInto: thisManagedContext)
        itemForSelected.quantityConsumed = Int32(quantity)
        itemForSelected.name = food.foodProContent
        itemForSelected.unitCalories = food.foodProCalorie
        itemForSelected.totalCalories = Double((itemForSelected.quantityConsumed)) * Double((itemForSelected.unitCalories))
        itemForSelected.quantity = food.foodProUnit
        itemForSelected.brand = food.foodProBrand
        itemForSelected.id = food.foodProId
        items.add(itemForSelected)
    }
    recentDay.items = items.copy() as! NSOrderedSet
    recentDay.currentDate = Date()
    try! thisManagedContext.save()
}


func postNotification(){
    NotificationCenter.default.post(name: Notification.Name(rawValue: IndexUpdateNotification), object: nil)
}

var dateFormatter: DateFormatter = {
    var dateformatter = DateFormatter()
    dateformatter.dateFormat = "MMM d, yyyy"
    return dateformatter
}()

func configureCell(_ cell: FoodCell, foodContent: String, caloriesContent: Double, brandContent: String, quantityContent: Double?,unitContent: String?){
    cell.foodLabel.text = foodContent
    cell.calorieLabel.text = String(caloriesContent) + " Cal"
    cell.brandLabel.text = brandContent
    cell.quantityLabel.text = (quantityContent == nil) ? "NA" : String(quantityContent!) + " " + unitContent!
}

func sameDay(_ dayLst:[Day],day: Date) -> Bool{
    if dayLst.count == 0{
        return false
    }
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    let recentDate = dayLst.first?.currentDate
    return calendar.isDate(day, inSameDayAs: recentDate! as Date)
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

func showLandscapeViewWithCoordinator(_ coordinator: UIViewControllerTransitionCoordinator, thisController: UIViewController){
    if landscapeViewController != nil {return}
    thisController.tabBarController?.tabBar.isHidden = true
    if thisController.presentedViewController != nil{
        thisController.dismiss(animated: true, completion: nil)
    }
    landscapeViewController = thisController.storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as?LandscapeViewController
    if let controller = landscapeViewController{
        controller.view.frame = thisController.view.bounds
        thisController.view.addSubview(controller.view)
        thisController.addChildViewController(controller)
        controller.didMove(toParentViewController: thisController)
    }
}

func hideLandscapeViewWithCoordinator(_ coordinator: UIViewControllerTransitionCoordinator, thisController: UIViewController){
    if let controller = landscapeViewController{
        thisController.tabBarController?.tabBar.isHidden = false
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        landscapeViewController = nil
    }
}

struct commonConstants{
    static let cellXib = "FoodCell"
    static let topInsets:CGFloat = 92
}

func isValidNumber(_ str:String) -> Bool{
    if str.isEmpty {
        return false
    }
    let newChar = CharacterSet(charactersIn: str)
    let boolValid = CharacterSet.decimalDigits.isSuperset(of: newChar)
    if boolValid{
        return true
    }else{
        let lst = str.components(separatedBy: ".")
        let newStr = lst.joined(separator: "")
        let currentChar = CharacterSet(charactersIn: newStr)
        if lst.count == 2 && !lst.contains("") && CharacterSet.decimalDigits.isSuperset(of: currentChar){
            return true
        }
        return false
    }
}

func makeAlert(_ message: String, vc: UIViewController, title: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17),NSForegroundColorAttributeName : UIColor.white]), forKey: "attributedTitle")
    alert.setValue(NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName : UIColor.white]), forKey: "attributedMessage")
    alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
    let subview = alert.view.subviews.first! as UIView
    let alertContentView = subview.subviews.first! as UIView
    alertContentView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    vc.present(alert, animated: true, completion: nil)
    alert.view.tintColor = UIColor.green
}

func makeAlertNoButton(_ message: String, vc: UIViewController, title: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17),NSForegroundColorAttributeName : UIColor.white]), forKey: "attributedTitle")
    alert.setValue(NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName : UIColor.white]), forKey: "attributedMessage")
    let subview = alert.view.subviews.first! as UIView
    let alertContentView = subview.subviews.first! as UIView
    alertContentView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
    vc.present(alert, animated: true, completion: nil)
    alert.view.tintColor = UIColor.green
}

func dismissPopup(_ vc: UIViewController, time: Double){
    let delayInSeconds = time
    let when = DispatchTime.now() + Double(Int64(delayInSeconds*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: when){
        vc.dismiss(animated: true, completion: nil)
    }
}



