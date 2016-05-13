//
//  ViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit

class CalorieCountViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let net = NetworkGrab()
    
    private struct commonConstants{
        static let rowHeight:CGFloat = 100
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

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return net.lst.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commonConstants.cellXib, forIndexPath: indexPath) as! FoodCell
        let foodItem = net.lst[indexPath.row]
        configureCell(cell, foodContent: foodItem.foodContent!, caloriesContent: foodItem.caloriesCount!)
        return cell
    }

    
    func configureCell(cell: FoodCell, foodContent: String, caloriesContent: Double){
        cell.foodLabel.text = foodContent
        cell.calorieLabel.text = String(caloriesContent) + " kCal"
    }
}

extension CalorieCountViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        let text = searchBar.text!
        let url = net.urlWithSearchText(text)
        net.performSearch(url){
            self.tableView.reloadData()
        }
    }
}






