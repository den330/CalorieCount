//
//  Day.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/14.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import CoreData
import CoreSpotlight
import MobileCoreServices


class Day: NSManagedObject {
    
    var searchableItem: CSSearchableItem{
        let item = CSSearchableItem(uniqueIdentifier: dateFormatter.string(from: currentDate), domainIdentifier: "Day", attributeSet: attributeSet)
        return item
    }
    
    internal var attributeSet: CSSearchableItemAttributeSet{
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
        attributeSet.title = dateFormatter.string(from: currentDate)
        var calories:Double = 0
        for i in items{
            let item = i as! ItemConsumed
            calories += item.totalCalories
        }
        attributeSet.contentDescription = "Total Calorie: \(calories) Cal"
        attributeSet.keywords = ["CR"]
        return attributeSet
    }



}
