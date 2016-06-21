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
import MessageUI

class StatisticTableViewController: UITableViewController{
    
    
    let fetchRequest = NSFetchRequest(entityName: "Day")
    var managedContext: NSManagedObjectContext!
    var isFirstTime = true
    var totalDays: Int!
    var totalCals: Double!
    
    @IBOutlet weak var FirstLineLabel: UILabel!
    @IBOutlet weak var SecondLineLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        fetchTotal()
        getAvg()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isFirstTime{
            fetchTotal()
            getAvg()
        }else{
            isFirstTime = false
        }
    }
    
    
    func fetchTotal(){
        let fetchRequest = NSFetchRequest(entityName: "ItemConsumed")
        fetchRequest.resultType = .DictionaryResultType
        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "Total"
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "totalCalories")])
        sumExpressionDesc.expressionResultType = .DoubleAttributeType
        
        fetchRequest.propertiesToFetch = [sumExpressionDesc]
        do{
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [NSDictionary]
            let resultDict = results.first!
            let total = resultDict["Total"] as! Double
            totalCals = total
            FirstLineLabel.text = "\(totalCals)" + " Cal"
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func fetchNumofDays(){
        let fetchRequest = NSFetchRequest(entityName: "Day")
        var error: NSError?
        let count = managedContext.countForFetchRequest(fetchRequest, error: &error)
        totalDays = count
    }
    
    func getAvg(){
        fetchNumofDays()
        do{
            var daysInCalc: Int
            var calInCalc: Double
            let results = try managedContext.executeFetchRequest(dayFetch) as! [Day]
            if sameDay(results,day: NSDate()){
                daysInCalc = totalDays - 1
                let items = results.first!.items!.mutableCopy() as! NSMutableOrderedSet
                var currentDayCal = 0.0
                for i in items{
                    let singleItem = i as! ItemConsumed
                    currentDayCal += singleItem.totalCalories as Double
                }
                calInCalc = totalCals - currentDayCal
            }else{
                daysInCalc = totalDays
                calInCalc = totalCals
            }

            let avg: Double
            avg = (daysInCalc == 0) ? 0.0 : calInCalc / Double(daysInCalc)
            SecondLineLabel.text = String(format: "%.2f", avg) + " Cal"
        }catch{
            print(error)
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
}

extension StatisticTableViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake{
            showEmail()
        }
    }
    
    func showEmail(){
        if presentedViewController != nil{
            dismissViewControllerAnimated(true,completion: nil)
        }
        makeEmail()
    }
    
    func makeEmail(){
        if MFMailComposeViewController.canSendMail(){
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject(NSLocalizedString("App Suggestion", comment: "Email Sub"))
            controller.setToRecipients(["yaxinyuan0910@gmail.com"])
            presentViewController(controller, animated: true, completion: nil)
        }
    }
}



