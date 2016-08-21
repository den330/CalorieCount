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
    var entryToEdit: ItemConsumed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let editEntry = entryToEdit else{
           return
        }
        nameField.text = editEntry.foodProContent
        brandField.text = editEntry.brand
        calorieField.text = String(editEntry.unitCalories)
        unitField.text = editEntry.foodProUnit
    }
    
    @IBAction func Save(sender: UIBarButtonItem) {
        if !isValidNumber(calorieField.text!){
            return
        }
        var entry: ItemConsumed
        if let editEntry = entryToEdit{
            entry = editEntry
        }else{
            let itemEntity = NSEntityDescription.entityForName("ItemConsumed", inManagedObjectContext: managedContext)
            entry = ItemConsumed(entity: itemEntity!, insertIntoManagedObjectContext: managedContext)
            entry.id = String(NSUserDefaults.standardUserDefaults().integerForKey("DIYID") + 1)
            entry.isMy = true
            NSUserDefaults.standardUserDefaults().setInteger(Int(entry.id)!, forKey: "DIYID")
        }
        if brandField.text! != ""{
            entry.brand = brandField.text!
        }
        entry.unitCalories = Double(calorieField.text!)!
        if unitField.text! != ""{
            entry.quantity = unitField.text!
        }
        try! managedContext.save()
        navigationController?.popViewControllerAnimated(true)
    }
}
