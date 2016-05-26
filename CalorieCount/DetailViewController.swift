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
    
    var foodSelected: Food?
    var managedContext: NSManagedObjectContext!
    var recentDay: Day?
    var itemForSelected: ItemConsumed?
    
    @IBOutlet weak var quantityLabel: UILabel!
    var currentfigure = 0
    
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
        if currentfigure > 0{
            currentfigure -= 1
            quantityLabel.text = String(currentfigure)
        }
    }
    
    @IBAction func saveButton(){

        if Int(quantityLabel.text!) > 0{
            let dayEntity = NSEntityDescription.entityForName("Day", inManagedObjectContext: managedContext)
            let itemEntity = NSEntityDescription.entityForName("ItemConsumed", inManagedObjectContext: managedContext)
            let dayFetch = NSFetchRequest(entityName: "Day")
            let sort = NSSortDescriptor(key: "currentDate", ascending: true)
            dayFetch.sortDescriptors = [sort]
            do{
                let results = try managedContext.executeFetchRequest(dayFetch) as! [Day]
                if sameDay(results){
                    recentDay = results.last!
                }else{
                    recentDay = Day(entity: dayEntity!, insertIntoManagedObjectContext: managedContext)
                }
                itemForSelected = ItemConsumed(entity: itemEntity!, insertIntoManagedObjectContext: managedContext)
                itemForSelected?.quantityConsumed = Int(quantityLabel.text!)
                itemForSelected?.name = foodSelected?.foodContent
                itemForSelected?.unitCalories = foodSelected?.caloriesCount
                itemForSelected?.totalCalories = Double((itemForSelected?.quantityConsumed)!) * Double((itemForSelected?.unitCalories)!)
                itemForSelected?.quantity = foodSelected?.quantity
                itemForSelected?.brand = foodSelected?.brandContent
                recentDay?.currentDate = NSDate()
                itemForSelected?.id = foodSelected?.id
                let items = recentDay!.items!.mutableCopy() as! NSMutableOrderedSet
                var existed: Bool = false
                for i in items{
                    let singleItem = i as! ItemConsumed
                    if itemForSelected!.id == singleItem.id{
                        existed = true
                        singleItem.quantityConsumed = Double(singleItem.quantityConsumed!) + Double(itemForSelected!.quantityConsumed!)
                        singleItem.totalCalories = Double(singleItem.totalCalories!) + Double(itemForSelected!.totalCalories!)
                    }
                }
                if !existed{
                    items.addObject(itemForSelected!)
                }
                recentDay?.items = items.copy() as? NSOrderedSet
                try managedContext.save()
            }catch let error as NSError{
                print("Error: \(error)" + "description \(error.localizedDescription)")
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    func sameDay(dayLst:[Day]) -> Bool{
        if dayLst.count == 0{
            return false
        }
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let currentDate = NSDate()
        let recentDate = dayLst.last?.currentDate
        return calendar!.isDate(currentDate, inSameDayAsDate: recentDate!)
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
