//
//  RecordTableViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/17.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import CoreSpotlight


class RecordTableViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController<Day>!
    let fetchRequest = NSFetchRequest<Day>(entityName: "Day")
    var managedContext: NSManagedObjectContext!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60
        let sortDescriptor = NSSortDescriptor(key: "currentDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print("Error: \(error.localizedDescription)")
        }
        tabBarController?.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        let rowNum = sectionInfo.numberOfObjects
        return rowNum
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        let day = fetchedResultsController.object(at: indexPath)
        configureCell(cell, day: day)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            let day = fetchedResultsController.object(at: indexPath)
            for item in day.items{
                let i = item as! ItemConsumed
                managedContext.delete(i)
            }
            managedContext.delete(day)
        }
        
            do{
                try managedContext.save()
                postNotification()
            }catch let error as NSError{
                print("Could not save delete: \(error)")
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    func configureCell(_ cell: UITableViewCell, day: Day){
        let items = day.items
        var totalCalories = 0.0
        for i in items{
            let item = i as! ItemConsumed
            totalCalories += Double(item.totalCalories)
        }
        let dateLabel =  cell.viewWithTag(1000) as! UILabel
        let caloriesLabel = cell.viewWithTag(1001) as! UILabel
        let date = dateFormatter.string(from: day.currentDate)
        dateLabel.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        caloriesLabel.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        if sameDay([day], day: Date()){
            dateLabel.text = "Today"
        }else{
            dateLabel.text = date
        }
        caloriesLabel.text = "Total: " + String(format: "%.2f", Double(totalCalories)) + " Cal"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showthatday", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showthatday"{
            let index = sender as! IndexPath
            let dayController = segue.destination as! DailyConsumeTableViewController
            dayController.day = fetchedResultsController.object(at: index)
            dayController.managedContext = managedContext
        }
    }
}

extension RecordTableViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!)
            let day = fetchedResultsController.object(at: indexPath!)
            configureCell(cell!, day: day)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake{
            let alert = UIAlertController(title: "Delete", message: "Delete All Records?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {[unowned self] _ in self.handleMotion()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert,animated: true, completion: nil)
            alert.view.tintColor = UIColor.red
        }
    }
    
    func handleMotion(){
        let days = fetchedResultsController.fetchedObjects!
        for day in days{
            for item in day.items{
                managedContext.delete(item as! ItemConsumed)
            }
            managedContext.delete(day)
            do{
                try managedContext.save()
                postNotification()
            }catch let error as NSError{
                print("Could not save delete: \(error)")
            }
        }
    }
}

extension RecordTableViewController: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            navigationController!.popViewController(animated: true)
    }
    
    
}




