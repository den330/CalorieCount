//
//  SearchController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 2016/9/28.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import UIKit

class SearchController: NSObject, UISearchResultsUpdating{
    let searchController: UISearchController!
    private weak var tableView: UITableView!
    
    
    init(tableView: UITableView){
        searchController = UISearchController(searchResultsController: nil)
        self.tableView = tableView
        super.init()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
      }
    
    func getText() -> String{
        return searchController.searchBar.text!
    }
    
    func isActive() -> Bool{
        return searchController.isActive
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: searchUpdateNotification), object: nil)
    }
}
