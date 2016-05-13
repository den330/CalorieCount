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
    
    private struct commonConstants{
        static let rowHeight:CGFloat = 80
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
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commonConstants.cellXib, forIndexPath: indexPath) as! FoodCell
        configureCell(cell, foodContent: "Carrot", caloriesContent: 37)
        return cell
    }

    
    func configureCell(cell: FoodCell, foodContent: String, caloriesContent: Double){
        cell.foodLabel.text = foodContent
        cell.calorieLabel.text = String(caloriesContent)
    }
}

extension CalorieCountViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        let net = NetworkGrab()
        let url = net.urlWithSearchText(searchBar.text!)
        net.performSearch(url)
    }
}






