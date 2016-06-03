//
//  functions.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/31.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import CoreData

var dateFormatter: NSDateFormatter = {
    var dateformatter = NSDateFormatter()
    dateformatter.dateStyle = .MediumStyle
    return dateformatter
}()

func sameDay(dayLst:[Day]) -> Bool{
    if dayLst.count == 0{
        return false
    }
    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
    let currentDate = NSDate()
    let recentDate = dayLst.first?.currentDate
    return calendar!.isDate(currentDate, inSameDayAsDate: recentDate!)
}

let dayFetch: NSFetchRequest = {
    let Fetch = NSFetchRequest(entityName: "Day")
    let sort = NSSortDescriptor(key: "currentDate", ascending: false)
    Fetch.sortDescriptors = [sort]
    Fetch.fetchLimit = 1
    return Fetch
}()

let itemConsumedFetch: NSFetchRequest = {
    let Fetch = NSFetchRequest(entityName: "ItemConsumed")
    let sort = NSSortDescriptor(key: "unitCalories", ascending: true)
    Fetch.sortDescriptors = [sort]
    return Fetch
}()
