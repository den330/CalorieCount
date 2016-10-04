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
    var slideToRight: UISwipeGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSet(vc: self, tableView: tableView)
        slideToRight = UISwipeGestureRecognizer(target: self, action: #selector(FavViewController.handleSwipeAction))
        tableView.addGestureRecognizer(slideToRight)
        slideToRight.cancelsTouchesInView = true
        let sortDescriptor = NSSortDescriptor(key: "unitCalories", ascending: true)
        let predicate = NSPredicate(format: "isFav==%@", true as CVarArg)
        searchCon = SearchController(tableView: tableView)
        dataSource = DataSource(tableView: tableView, predicate: predicate, sort: sortDescriptor, context: managedContext, searchCon: searchCon, predicateStr: "isFav == %@")
        tableView.delegate = self
        tableView.dataSource = dataSource
    }
    
    func handleSwipeAction(){
        handleSwipe(slideToRight, tableView: tableView, view: view, context: managedContext, dataSource: dataSource)
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
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        motionEndHandle(motion, with: event, dataSource: dataSource, vc: self, context: managedContext, filteredMessage: "Delete Fav Containing", message: "Delete All Fav")
    }
}






