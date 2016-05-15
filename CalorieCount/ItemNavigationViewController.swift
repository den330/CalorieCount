//
//  ItemNavigationViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/15.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit

class ItemNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func shouldAutorotate() -> Bool {
        let currentViewController = self.topViewController!
        if currentViewController.isKindOfClass(DailyConsumeTableViewController){
            return false
        }
        return true
    }


}
