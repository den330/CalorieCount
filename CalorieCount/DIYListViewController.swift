//
//  DIYListViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/8/21.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData

class DIYListViewController: UIViewController, UITableViewDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController<ItemConsumed>!
    let fetchRequest = NSFetchRequest<ItemConsumed>(entityName: "ItemConsumed")
    var managedContext: NSManagedObjectContext!
    var itemForSelected: ItemConsumed!
    var recentDay: Day!
    var searchCon: SearchController!
    var dataSource: DataSource!
    var filteredItem = [ItemConsumed]()
    var slideToRight: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSet(vc: self, tableView: tableView)
        slideToRight = UISwipeGestureRecognizer(target: self, action: #selector(DIYListViewController.handleSwipeAction))
        slideToRight.cancelsTouchesInView = true
        tableView.addGestureRecognizer(slideToRight)
        let sortDescriptor = NSSortDescriptor(key: "unitCalories", ascending: true)
        let predicate = NSPredicate(format: "isMy==%@", true as CVarArg)
        searchCon = SearchController(tableView: tableView)
        dataSource = DataSource(tableView: tableView, predicate: predicate, sort: sortDescriptor, context: managedContext, searchCon: searchCon, predicateStr: "isMy == %@")
        tableView.delegate = self
        tableView.dataSource = dataSource
        firstTimePopUp()
    }
    
    func firstTimePopUp(){
        if !UserDefaults.standard.bool(forKey: "DIYAgain"){
            let message = "Can’t Find What You Want From Our Server Yet You Did Learn the Calorie Amount Of a Certain Item From Some Other Source? Then Build An Item For Yourself So That You Can Add It To Your Daily Record Directly From This Tab"
            makeAlert(message, vc: self.parent!, title: "Tips")
            UserDefaults.standard.set(true, forKey: "DIYAgain")
        }
    }
    
    func handleSwipeAction(){
        handleSwipe(slideToRight, tableView: tableView, view: view, context: managedContext, dataSource: dataSource)
    }
    
    @IBAction func addEntry(_ sender: UIBarButtonItem) {
        let title = "DIY"
        let message = "Add Your Item Here"
        let color = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        let ac = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        ac.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 25),NSForegroundColorAttributeName : color]), forKey: "attributedTitle")
        ac.setValue(NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 20),NSForegroundColorAttributeName : color]), forKey: "attributedMessage")
        ac.addTextField(configurationHandler: {textfield in
        textfield.placeholder = "Calorie Amount"} )
        ac.addTextField(configurationHandler: {textfield in
            textfield.placeholder = "Brand(Optional)"} )
        ac.addTextField(configurationHandler: {textfield in
            textfield.placeholder = "Unit(Optional)"} )
        ac.addTextField(configurationHandler: {textfield in
            textfield.placeholder = "Name(Optional)"} )
        let action = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { _ in
            if !isValidNumber(ac.textFields![0].text!){
                makeAlert("Invalid Input As Calorie Amount", vc: self, title: "Invalid Input")
            }else{
                makeAlertNoButton("Successfully Saved", vc: self, title: "Success")
                dismissPopup(self, time: 1.0)
                let brandField = ac.textFields![1]
                let nameField = ac.textFields![3]
                let unitField = ac.textFields![2]
                let calorieField = ac.textFields![0]
                self.saveEntry(brandField, nameField: nameField, unitField: unitField, calorieField: calorieField)
            }
        })
        ac.addAction(action)
        let action2 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        ac.addAction(action2)
        present(ac, animated: true, completion: nil)
        ac.view.tintColor = color
    }
    
    func saveEntry(_ brandField: UITextField, nameField: UITextField, unitField: UITextField, calorieField: UITextField){
        let itemEntity = NSEntityDescription.entity(forEntityName: "ItemConsumed", in: managedContext)
        let entry = ItemConsumed(entity: itemEntity!, insertInto: managedContext)
        entry.isMy = true
        entry.id = String(UserDefaults.standard.integer(forKey: "DIYID") + 1)
        UserDefaults.standard.set(Int(entry.id)!, forKey: "DIYID")
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "presentPopUp", sender: dataSource.getObjAt(indexPath: indexPath as NSIndexPath) )
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPopUp"{
            let item = sender as! ItemConsumed
            let DestController = segue.destination as! DetailViewController
            DestController.itemCon = item
            DestController.managedContext = managedContext
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        motionEndHandle(motion, with: event, dataSource: dataSource, vc: self, context: managedContext, filteredMessage: "Delete All DIY Containing", message: "Delete All DIY")
    }
}









