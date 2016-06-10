//
//  AlertController.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/6/10.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import UIKit

protocol MyAlertControllerDelegate: class
{
    func showEmail()
}

class MyAlertController: UIAlertController{
    weak var delegate: MyAlertControllerDelegate?
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if  motion == .MotionShake{
            delegate!.showEmail()
        }
    }
}

