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

class FavViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<ItemConsumed>!
    let fetchRequest = NSFetchRequest<ItemConsumed>(entityName: "ItemConsumed")
    
    var managedContext: NSManagedObjectContext!
    var itemForSelected: ItemConsumed!
    var recentDay: Day!
    let searchController = UISearchController(searchResultsController: nil)
    var filteredItem = [ItemConsumed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.delegate = self
        tableView.dataSource = self
        let cellNib = UINib(nibName: commonConstants.cellXib, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: commonConstants.cellXib)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        let slideToRight = UISwipeGestureRecognizer(target: self, action: #selector(FavViewController.handleSwipe))
        tableView.addGestureRecognizer(slideToRight)
        slideToRight.cancelsTouchesInView = true
        let sortDescriptor = NSSortDescriptor(key: "unitCalories", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "isFav==%@", true as CVarArg)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""{
            return filteredItem.count
        }
        let sectionInfo = fetchedResultsController.sections![section]
        let rowNum = sectionInfo.numberOfObjects
        return rowNum
    }
    
    func handleSwipe(_ Swipe: UISwipeGestureRecognizer){
        if Swipe.direction == .right{
            let touchPoint = Swipe.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: touchPoint)
            quickSave(indexPath)
        }
    }
    
    func quickSave(_ indexPath: IndexPath?){
        if let indexPath = indexPath{
            let item: ItemConsumed
            if searchController.isActive && searchController.searchBar.text != ""{
                item = filteredItem[(indexPath as NSIndexPath).row]
            }else{
                item = fetchedResultsController.object(at: indexPath) 
            }
            save(managedContext, food: item, quantity: 1)
            let hudView: HudView = HudView.hudInView(view, animated: true)
            hudView.text = "1 Unit Saved"
            let cell = tableView.cellForRow(at: indexPath) as! FoodCell
            let calorieText = cell.calorieLabel.text
            cell.calorieLabel.text = "1 Unit Added"
            postNotification()
            let delayInSeconds = 0.6
            let when = DispatchTime.now() + Double(Int64(delayInSeconds*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when){
                cell.calorieLabel.text = calorieText
                hudView.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commonConstants.cellXib, for: indexPath) as! FoodCell
        let item:ItemConsumed
        if searchController.isActive && searchController.searchBar.text != ""{
            item = filteredItem[(indexPath as NSIndexPath).row]
        }else{
            item = fetchedResultsController.object(at: indexPath) 
        }
        cell.brandLabel.text = item.brand
        cell.calorieLabel.text = String(item.unitCalories) + " " + "Cal"
        cell.foodLabel.text = item.name
        cell.quantityLabel.text = item.quantity
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            let item: ItemConsumed
            if searchController.isActive  && searchController.searchBar.text != ""{
                item = filteredItem[(indexPath as NSIndexPath).row]
                managedContext.delete(item)
                try! managedContext.save()
                filteredItem = filterItemForSearchText(searchController.searchBar.text!, resultCon: fetchedResultsController)
                tableView.reloadData()
            }else{
                item = fetchedResultsController.object(at: indexPath) 
                managedContext.delete(item)
                try! managedContext.save()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive  && searchController.searchBar.text != ""{
            performSegue(withIdentifier: "showPop", sender: filteredItem[(indexPath as NSIndexPath).row])
        }else{
            performSegue(withIdentifier: "showPop", sender: fetchedResultsController.object(at: indexPath) )
        }
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



extension FavViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if searchController.isActive && searchController.searchBar.text != ""{
            return
        }
        switch type{
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake{
            let alert: UIAlertController
            if searchController.isActive && searchController.searchBar.text != ""{
                let text = searchController.searchBar.text!
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
        if searchController.isActive && searchController.searchBar.text != ""{
            objects = filteredItem
        }else{
            objects = fetchedResultsController.fetchedObjects!
        }
        for object in objects{
            managedContext.delete(object)
        }
        do{
            try managedContext.save()
            if searchController.isActive && searchController.searchBar.text != ""{
                filteredItem = filterItemForSearchText(searchController.searchBar.text!, resultCon: fetchedResultsController)
                tableView.reloadData()
            }
        }catch let error as NSError{
            print("Could not save delete: \(error)")
        }
    }
}

extension FavViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filteredItem = filterItemForSearchText(searchController.searchBar.text!, resultCon: fetchedResultsController)
        tableView.reloadData()
    }
}



