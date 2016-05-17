//
//  ViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData

class CalorieCountViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    var managedContext: NSManagedObjectContext!
    var NaviController: UINavigationController?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let net = NetworkGrab()
    
    private struct commonConstants{
        static let rowHeight:CGFloat = 170
        static let topInsets:CGFloat = 64
        static let cellXib = "FoodCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        tableView.contentInset = UIEdgeInsets(top: commonConstants.topInsets, left: 0, bottom: 0, right: 0)
        let cellNib = UINib(nibName: commonConstants.cellXib, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: commonConstants.cellXib)
        tableView.rowHeight = commonConstants.rowHeight
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        switch newCollection.verticalSizeClass{
            case .Compact:
                showRecordController(coordinator)
            case .Regular, .Unspecified:
                hideRecordController(coordinator)
        }
    }
    
    func showRecordController(coordinator: UIViewControllerTransitionCoordinator){
        precondition(NaviController == nil)
        if self.presentedViewController != nil{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        searchBar.resignFirstResponder()
        NaviController = storyboard!.instantiateViewControllerWithIdentifier("ItemNavigationController") as? UINavigationController
        if let controller = NaviController{
            let desController = controller.topViewController as! RecordTableViewController
            desController.managedContext = managedContext
            controller.view.frame = view.bounds
            view.addSubview(controller.view)
            addChildViewController(controller)
            controller.didMoveToParentViewController(self)
        }
    }
    
    
    
    
    func hideRecordController(coordinator: UIViewControllerTransitionCoordinator){
        if let controller = NaviController{
            controller.willMoveToParentViewController(nil)
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
            NaviController = nil
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch net.state{
            case .NotFound, .Searching: return 1
            case .NotSearchedYet: return 0
            case .SearchSuccess(let lst): return lst.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commonConstants.cellXib, forIndexPath: indexPath) as! FoodCell
        switch net.state{
            case .SearchSuccess(let lst):
                let foodItem = lst[indexPath.row]
                configureCell(cell, foodContent: foodItem.foodContent!, caloriesContent: foodItem.caloriesCount!, brandContent: foodItem.brandContent!,quantityContent: foodItem.quantity!)
                return cell
            case .NotFound:
                configureCell(cell, foodContent: "NA", caloriesContent: 0,brandContent: "NA",quantityContent: "NA")
            case .Searching:
                configureCell(cell, foodContent: "Searching", caloriesContent: 0, brandContent: "Searching",quantityContent: "Searching")
            default: break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch net.state{
            case .SearchSuccess( _):
                return indexPath
            default: return nil
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showDetail", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail"{
            let detailController = segue.destinationViewController as! DetailViewController
            let index = sender as! NSIndexPath
            if let lst = net.state.get(){
                detailController.foodSelected = lst[index.row]
                detailController.managedContext = managedContext
            }
        }
    }

    
    func configureCell(cell: FoodCell, foodContent: String, caloriesContent: Double, brandContent: String, quantityContent: String){
        cell.foodLabel.text = foodContent
        cell.calorieLabel.text = String(caloriesContent) + " kCal"
        cell.brandLabel.text = brandContent
        cell.quantityLabel.text = quantityContent
        
    }
}

extension CalorieCountViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        let text = searchBar.text!
        let url = net.urlWithSearchText(text)
        net.performSearch(url){
            self.tableView.reloadData()
        }
        tableView.reloadData()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}






