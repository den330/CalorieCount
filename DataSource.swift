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

class DataSource:NSObject, UITableViewDataSource{
    private let fetchRequest: NSFetchRequest<ItemConsumed>!
    private let fetchedObjectController: NSFetchedResultsController<ItemConsumed>!
    private let tableView: UITableView!
    private let context: NSManagedObjectContext!
    private var searchController: SearchController!
    var filteredItems: [ItemConsumed]!

    
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
        try! fetchedObjectController.performFetch()
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
    
    func updateFilteredItems(){
        let list = fetchedObjectController.fetchedObjects!
        filteredItems = list.filter{ item in return item.foodProContent.lowercased().contains(searchController.getText().lowercased())}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive(){
            updateFilteredItems()
            return filteredItems.count
        }
        return fetchedObjectController.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commonConstants.cellXib, for: indexPath) as! FoodCell
        let item:ItemConsumed
        if searchActive(){
            item = filteredItems[(indexPath as NSIndexPath).row]
        }else{
            item = fetchedObjectController.object(at: indexPath)
        }
        cell.brandLabel.text = item.brand
        cell.calorieLabel.text = String(item.unitCalories) + " " + "Cal"
        cell.foodLabel.text = item.name
        cell.quantityLabel.text = item.quantity
        return cell
    }
}


extension DataSource: NSFetchedResultsControllerDelegate{

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        getTableView().beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let tableView = getTableView()
        if searchActive(){
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
        getTableView().endUpdates()
    }
}
