//
//  DataSource.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 2016/9/28.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let searchUpdateNotification = "Update Notification"

class DataSource:NSObject, UITableViewDataSource{
    private let fetchRequest: NSFetchRequest<ItemConsumed>!
    private let fetchedObjectController: NSFetchedResultsController<ItemConsumed>!
    var tableView: UITableView!
    private var context: NSManagedObjectContext!
    private var searchController: SearchController!
    var filteredItems: [ItemConsumed]!
    var observer: AnyObject!
    

    
    init(tableView: UITableView, predicate: NSPredicate, sort: NSSortDescriptor, context: NSManagedObjectContext, searchCon: SearchController
        ){
        self.tableView = tableView
        self.context = context
        self.searchController = searchCon
        
        searchController = SearchController(tableView: self.tableView)
        fetchRequest = NSFetchRequest<ItemConsumed>(entityName: "ItemConsumed")
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.predicate = predicate
        fetchedObjectController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        fetchedObjectController.delegate = self
        try! fetchedObjectController.performFetch()
        listenForSearchUpdate()
    }
    
    func getObjAt(indexPath: NSIndexPath) -> ItemConsumed{
        return fetchedObjectController.object(at: indexPath as IndexPath)
    }
    
    func getAllObj() -> [ItemConsumed]{
        return fetchedObjectController.fetchedObjects!
    }
    
    func getTableView() -> UITableView{
        return tableView
    }
    
    func getSearchController() -> SearchController{
        return searchController
    }
    
    func searchActive() -> Bool{
        return searchController.isActive() && searchController.getText() != ""
    }
    
    func updateFilteredItems() -> [ItemConsumed]{
        let list = fetchedObjectController.fetchedObjects!
        let filtered = list.filter{ item in return item.foodProContent.lowercased().contains(searchController.getText().lowercased())}
        return filtered
    }
    
    func listenForSearchUpdate(){
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: searchUpdateNotification), object: nil, queue: nil){
            [unowned self] notification in
            if self.searchActive(){
                let firstPredicate = NSPredicate(format: "name CONTAINS[c] %@" , self.searchController.getText())
                let secondPredicate = NSPredicate(format: "isFav == %@", true as CVarArg)
                self.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [firstPredicate, secondPredicate])
            }else{
                self.fetchRequest.predicate =  NSPredicate(format: "isFav == %@", true as CVarArg)
            }
            try! self.fetchedObjectController.performFetch()
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedObjectController.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commonConstants.cellXib, for: indexPath) as! FoodCell
        let item:ItemConsumed
        item = fetchedObjectController.object(at: indexPath)
        cell.brandLabel.text = item.brand
        cell.calorieLabel.text = String(item.unitCalories) + " " + "Cal"
        cell.foodLabel.text = item.name
        cell.quantityLabel.text = item.quantity
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            let item: ItemConsumed
            item = getObjAt(indexPath: indexPath as NSIndexPath)
            context.delete(item)
            try! context.save()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
}


extension DataSource: NSFetchedResultsControllerDelegate{

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
}
