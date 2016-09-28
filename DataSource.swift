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

class DataSource:UITableViewDataSource{
    private let fetchRequest: NSFetchRequest<ItemConsumed>!
    private let fetchedObjectController: NSFetchedResultsController<ItemConsumed>!
    private let tableView: UITableView!
    private let context: NSManagedObjectContext!
    private var searchController: SearchController!
    private var filteredItems: [ItemConsumed]!

    
    init(tableView: UITableView, predicate: NSPredicate, sort: NSSortDescriptor, context: NSManagedObjectContext, searchCon: SearchController
        ){
        self.tableView = tableView
        self.context = context
        self.searchController = searchCon
        searchController = SearchController(tableView: self.tableView)
        fetchRequest = NSFetchRequest<ItemConsumed>(entityName: "ItemConsumed")
        self.fetchRequest.sortDescriptors = [sort]
        self.fetchRequest.predicate = predicate
        fetchedObjectController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func searchActive() -> Bool{
        return searchController.isActive() && searchController.getText() != ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive(){
            let list = fetchedObjectController.fetchedObjects!
            filteredItems = list.filter{ item in return item.foodProContent.lowercased().contains(searchController.getText().lowercased())}
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
