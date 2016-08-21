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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.scrollEnabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.scrollEnabled = true
    }

}