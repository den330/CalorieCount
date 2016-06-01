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
        FirstLineLabel.text = "1 ITtdasdasdasodpasdasdasofajoewjfoawfoiwaejfoiawejfoiawefiojwaeoifjaweoifjwaeiofwe"
        SecondLineLabel.text = "2"
        ThirdLineLabel.text = "3"
    }
    



}
