//
//  LandscapeViewController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/6/24.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import UIKit

class LandscapeViewController: UIViewController{
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.isScrollEnabled = true
    }

}
