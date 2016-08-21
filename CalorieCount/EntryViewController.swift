//
//  EntryViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/8/21.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData

class EntryViewController: UIViewController{
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var calorieField: UITextField!
    
    @IBOutlet weak var brandField: UITextField!
    
    @IBOutlet weak var unitField: UITextField!
    
    var managedContext: NSManagedObjectContext!
    
    @IBAction func Save(sender: UIBarButtonItem) {
        if !isValidNumber(calorieField.text!){
            makeAlert("Invalid Input On Calorie Field", vc: self, title: "Warning")
            return
        }
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
        let hudView: HudView = HudView.hudInView(view, animated: true)
        hudView.text = "Saved"
        let delayInSeconds = 0.6
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds*Double(NSEC_PER_SEC)))
        dispatch_after(when, dispatch_get_main_queue()){
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
