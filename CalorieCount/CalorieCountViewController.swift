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
    let transition = DetailAnimationController()
    
    

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
        tableView.contentInset = UIEdgeInsets(top: commonConstants.topInsets, left: 0, bottom: 0, right: 0)
        let cellNib = UINib(nibName: commonConstants.cellXib, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: commonConstants.cellXib)
        tableView.rowHeight = commonConstants.rowHeight
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().objectForKey("knowDelete") == nil{
            let message = "You can delete your calorie record(single item or entire day) by swiping (to the left)"
            let alert = UIAlertController(title: "FYI", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.setValue(NSAttributedString(string: "FYI", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17),NSForegroundColorAttributeName : UIColor.whiteColor()]), forKey: "attributedTitle")
            alert.setValue(NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15),NSForegroundColorAttributeName : UIColor.yellowColor()]), forKey: "attributedMessage")
            alert.addAction(UIAlertAction(title: "Got it", style: .Default, handler: nil))
            let subview = alert.view.subviews.first! as UIView
            let alertContentView = subview.subviews.first! as UIView
            alertContentView.backgroundColor = UIColor.redColor()
            presentViewController(alert, animated: true, completion: nil)
            alert.view.tintColor = UIColor.greenColor()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "knowDelete")
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch net.state{
            case .NotFound, .Searching: return 1
            case .NotSearchedYet: return 1
            case .SearchSuccess(let lst): return lst.count
            case .NoConnection: return 1
            }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commonConstants.cellXib, forIndexPath: indexPath) as! FoodCell
        cell.selectionStyle = .None
        switch net.state{
            case .SearchSuccess(let lst):
                cell.selectionStyle = .Default
                let foodItem = lst[indexPath.row]
                configureCell(cell, foodContent: foodItem.foodContent!, caloriesContent: foodItem.caloriesCount!, brandContent: foodItem.brandContent!,quantityContent: foodItem.quantity,unitContent: foodItem.unit)
                return cell
            case .NotFound:
                configureCell(cell, foodContent: "NA", caloriesContent: 0,brandContent: "NA",quantityContent: nil,unitContent: nil)
            case .NoConnection:
                configureCell(cell, foodContent: "No Connection", caloriesContent: 0, brandContent: "NA", quantityContent: nil, unitContent: nil)
            case .Searching:
                configureCell(cell, foodContent: "Searching", caloriesContent: 0, brandContent: "Searching",quantityContent: nil,unitContent: nil)
            case .NotSearchedYet:
                configureCell(cell, foodContent: "Click Search bar to start search", caloriesContent: 0, brandContent: "", quantityContent: nil,unitContent: nil)
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
        transition.presenting = true
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showDetail", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail"{
            let detailController = segue.destinationViewController as! DetailViewController
            detailController.transitioningDelegate = self
            let index = sender as! NSIndexPath
            if let lst = net.state.get(){
                detailController.foodSelected = lst[index.row]
                detailController.managedContext = managedContext
            }
        }
    }

    
    func configureCell(cell: FoodCell, foodContent: String, caloriesContent: Double, brandContent: String, quantityContent: Double?,unitContent: String?){
        cell.foodLabel.text = foodContent
        cell.calorieLabel.text = String(caloriesContent) + " Cal"
        cell.brandLabel.text = brandContent
        cell.quantityLabel.text = (quantityContent == nil) ? "NA" : String(quantityContent!) + " " + unitContent!
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


extension CalorieCountViewController: UIViewControllerTransitioningDelegate{
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}






