//
//  FavViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/6/12.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class FavViewController: UIViewController, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var managedContext: NSManagedObjectContext!
    var itemForSelected: ItemConsumed!
    var recentDay: Day!
    var dataSource: DataSource!
    var searchCon: SearchController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSet()
        let sortDescriptor = NSSortDescriptor(key: "unitCalories", ascending: true)
        let predicate = NSPredicate(format: "isFav==%@", true as CVarArg)
        searchCon = SearchController(tableView: tableView)
        dataSource = DataSource(tableView: tableView, predicate: predicate, sort: sortDescriptor, context: managedContext, searchCon: searchCon)
        tableView.delegate = self
        tableView.dataSource = dataSource
        
    }
    
    func tableViewSet(){
        definesPresentationContext = true
        
        let cellNib = UINib(nibName: commonConstants.cellXib, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: commonConstants.cellXib)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        let slideToRight = UISwipeGestureRecognizer(target: self, action: #selector(FavViewController.handleSwipe))
        tableView.addGestureRecognizer(slideToRight)
        slideToRight.cancelsTouchesInView = true
    }
    
    func handleSwipe(_ Swipe: UISwipeGestureRecognizer){
        if Swipe.direction == .right{
           let touchPoint = Swipe.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: touchPoint)
            quickSave(indexPath)
            let cell = tableView.cellForRow(at: indexPath!) as! FoodCell
            let calorieText = cell.calorieLabel.text
            cell.calorieLabel.text = "1 Unit Added"
            let hudView: HudView = HudView.hudInView(view, animated: true)
            hudView.text = "1 Unit Saved"
            let delayInSeconds = 0.6
            let when = DispatchTime.now() + Double(Int64(delayInSeconds*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when){
                let cell = self.tableView.cellForRow(at: indexPath!) as! FoodCell
                cell.calorieLabel.text = calorieText
                hudView.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func quickSave(_ indexPath: IndexPath?){
        if let indexPath = indexPath{
            let item: ItemConsumed
            item = dataSource.getObjAt(indexPath: indexPath as NSIndexPath)
            save(managedContext, food: item, quantity: 1)
            postNotification()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPop", sender: dataSource.getObjAt(indexPath: indexPath as NSIndexPath) )
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPop"{
            let item = sender as! ItemConsumed
            let DestController = segue.destination as! DetailViewController
            DestController.itemCon = item
            DestController.managedContext = managedContext
        }
    }
}



extension FavViewController{
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake{
            let alert: UIAlertController
            if dataSource.searchActive(){
                let text = dataSource.getSearchController().getText()
                alert = UIAlertController(title: "Delete", message: "Delete All Fav Containing \(text)?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {[unowned self] _ in self.handleMotion()}))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                present(alert,animated: true, completion: nil)
                alert.view.tintColor = UIColor.red
            }else{
                alert = UIAlertController(title: "Delete", message: "Delete All Fav?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {[unowned self] _ in self.handleMotion()}))
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                present(alert,animated: true, completion: nil)
                alert.view.tintColor = UIColor.red
            }
        }
    }
    
    func handleMotion(){
        let objects: [ItemConsumed]
        objects = dataSource.getAllObj()
        for object in objects{
            managedContext.delete(object)
        }
        try! managedContext.save()
    }
}





