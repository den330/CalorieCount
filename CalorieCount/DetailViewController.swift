//
//  DetailViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/13.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class DetailViewController: UIViewController {
    
    var foodSelected: Food?
    var managedContext: NSManagedObjectContext!
    var recentDay: Day!
    var itemForSelected: ItemConsumed!
    var itemCon: ItemConsumed!
    
    @IBOutlet weak var quantityLabel: UILabel!
    var currentfigure = 1
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("haha")
        let gesture = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.close))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    @IBAction func addButton(){
        currentfigure = Int(quantityLabel.text!)!
        currentfigure += 1
        quantityLabel.text = String(currentfigure)
    }
    
    @IBAction func minusButton(){
        currentfigure = Int(quantityLabel.text!)!
        if currentfigure > 1{
            currentfigure -= 1
            quantityLabel.text = String(currentfigure)
        }
    }
    
    @IBAction func saveButton(){
        let hudView = HudView.hudInView(view, animated: true)
        hudView.text = "Saved"
        saveItem()
        let delayInSeconds = 0.6
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds*Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_main_queue()){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func saveItem(){
        let dayEntity = NSEntityDescription.entityForName("Day", inManagedObjectContext: managedContext)
        let itemEntity = NSEntityDescription.entityForName("ItemConsumed", inManagedObjectContext: managedContext)
        if let foodS = foodSelected{
            print("here")
            do{
                let results = try managedContext.executeFetchRequest(dayFetch) as! [Day]
                if sameDay(results){
                    recentDay = results.first!
                }else{
                    recentDay = Day(entity: dayEntity!, insertIntoManagedObjectContext: managedContext)
                }
                let items = recentDay.items!.mutableCopy() as! NSMutableOrderedSet
                var existed: Bool = false
                for i in items{
                    let singleItem = i as! ItemConsumed
                    if singleItem.id == foodS.id{
                        existed = true
                        singleItem.quantityConsumed = singleItem.quantityConsumed + currentfigure
                        let newAddedCalories = foodS.caloriesCount! * Double(currentfigure)
                        singleItem.totalCalories = Double(singleItem.totalCalories) + newAddedCalories
                        break
                    }
                }
                if !existed{
                    itemForSelected = ItemConsumed(entity: itemEntity!, insertIntoManagedObjectContext: managedContext)
                    itemForSelected.quantityConsumed = Int32(quantityLabel.text!)!
                    itemForSelected.name = foodS.foodContent
                    itemForSelected.unitCalories = foodS.caloriesCount!
                    itemForSelected.totalCalories = Double((itemForSelected.quantityConsumed)) * Double((itemForSelected.unitCalories))
                    if let quantity = foodS.quantity, unit = foodS.unit{
                        itemForSelected.quantity = String(quantity) + " " + unit
                    }
                    itemForSelected.brand = foodS.brandContent
                    itemForSelected.id = foodS.id!
                    items.addObject(itemForSelected)
                }
                recentDay.items = items.copy() as? NSOrderedSet
                recentDay.currentDate = NSDate()
                try managedContext.save()
            }catch let error as NSError{
                print("Error: \(error)" + "description \(error.localizedDescription)")
            }
        }else{
            print("123here")
            do{
                let results = try managedContext.executeFetchRequest(dayFetch) as! [Day]
                if sameDay(results){
                    print("before")
                    recentDay = results.first!
                    print("after")
                }else{
                    recentDay = Day(entity: dayEntity!, insertIntoManagedObjectContext: managedContext)
                }
                let items = recentDay.items!.mutableCopy() as! NSMutableOrderedSet
                var existed: Bool = false
                for i in items{
                    let singleItem = i as! ItemConsumed
                    if singleItem.id == itemCon.id{
                        existed = true
                        singleItem.quantityConsumed = singleItem.quantityConsumed + currentfigure
                        let newAddedCalories = itemCon.unitCalories * Double(currentfigure)
                        singleItem.totalCalories = Double(singleItem.totalCalories) + newAddedCalories
                        break
                    }
                }
                if !existed{
                    itemForSelected = ItemConsumed(entity: itemEntity!, insertIntoManagedObjectContext: managedContext)
                    itemForSelected.brand = itemCon.brand
                    itemForSelected.id = itemCon.id
                    itemForSelected.unitCalories = itemCon.unitCalories
                    itemForSelected.name = itemCon.name
                    itemForSelected.isFav = false
                    itemForSelected.quantity = itemCon.quantity
                    itemForSelected.quantityConsumed = Int32(currentfigure)
                    itemForSelected.totalCalories = itemForSelected.unitCalories * Double(itemForSelected.quantityConsumed)
                    items.addObject(itemForSelected)
                }
                recentDay.items = items.copy() as? NSOrderedSet
                recentDay.currentDate = NSDate()
                try managedContext.save()
            }catch let error as NSError{
                print("Error: \(error)" + "description \(error.localizedDescription)")
            }
            
        }
    }
    
    
    @IBAction func close(){
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DetailPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}


extension DetailViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return(touch.view === self.view)
    }
}


extension DetailViewController: MFMailComposeViewControllerDelegate{
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
