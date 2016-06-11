//
//  DetailViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/13.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var foodSelected: Food!
    var managedContext: NSManagedObjectContext!
    var recentDay: Day!
    var itemForSelected: ItemConsumed!
    
    @IBOutlet weak var quantityLabel: UILabel!
    var currentfigure = 1
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let dayEntity = NSEntityDescription.entityForName("Day", inManagedObjectContext: managedContext)
        let itemEntity = NSEntityDescription.entityForName("ItemConsumed", inManagedObjectContext: managedContext)
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
                if singleItem.id == foodSelected.id{
                    existed = true
                    singleItem.quantityConsumed = Double(singleItem.quantityConsumed!) + Double(currentfigure)
                    let newAddedCalories = foodSelected.caloriesCount! * Double(currentfigure)
                    singleItem.totalCalories = Double(singleItem.totalCalories!) + newAddedCalories
                   break
                }
            }
            if !existed{
                itemForSelected = ItemConsumed(entity: itemEntity!, insertIntoManagedObjectContext: managedContext)
                itemForSelected.quantityConsumed = Int(quantityLabel.text!)
                itemForSelected.name = foodSelected.foodContent
                itemForSelected.unitCalories = foodSelected.caloriesCount
                itemForSelected.totalCalories = Double((itemForSelected.quantityConsumed)!) * Double((itemForSelected.unitCalories)!)
                if let quantity = foodSelected.quantity, unit = foodSelected.unit{
                    itemForSelected.quantity = String(quantity) + " " + unit
                }
                itemForSelected.brand = foodSelected.brandContent
                recentDay.currentDate = NSDate()
                itemForSelected.id = foodSelected.id
                items.addObject(itemForSelected)
            }
            recentDay.items = items.copy() as? NSOrderedSet
            try managedContext.save()
        }catch let error as NSError{
            print("Error: \(error)" + "description \(error.localizedDescription)")
        }
        let delayInSeconds = 0.6
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds*Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_main_queue()){
            self.dismissViewControllerAnimated(true, completion: nil)
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
