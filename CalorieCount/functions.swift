//
//  functions.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/31.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation

var dateFormatter: NSDateFormatter = {
    var dateformatter = NSDateFormatter()
    dateformatter.dateStyle = .MediumStyle
    return dateformatter
}()
