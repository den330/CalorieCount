//
//  StatisticTableViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/6/1.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class StatisticTableViewController: UITableViewController{
    
    var fetchedResultsController: NSFetchedResultsController!
    let fetchRequest = NSFetchRequest(entityName: "Day")
    var managedContext: NSManagedObjectContext!
    
    @IBOutlet weak var FirstLineLabel: UILabel!
    @IBOutlet weak var SecondLineLabel: UILabel!
    @IBOutlet weak var ThirdLineLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        let sortDescriptor = NSSortDescriptor(key: "currentDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print("Error: \(error.localizedDescription)")
        }
        let totalCalories = "0"
        let avgCalories = "0"
        let lastCalories = "0"
        
        FirstLineLabel.text = totalCalories + " Cal"
        SecondLineLabel.text = avgCalories + " Cal"
        ThirdLineLabel.text = lastCalories + " Cal"
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    



}


extension StatisticTableViewController: NSFetchedResultsControllerDelegate{
}
