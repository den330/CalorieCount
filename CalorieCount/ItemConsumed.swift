//
//  ItemConsumed.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/14.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import CoreData


class ItemConsumed: NSManagedObject, FoodProtocol {
    var foodProContent: String{
        get{
            return name
        }
    }
    
    var foodProCalorie: Double{
        get{
            return unitCalories
        }
    }
    
    var foodProBrand: String{
        get{
            return brand
        }
    }
    
    var foodProId: String{
        get{
            return id
        }
    }
    
    var foodProUnit: String{
        get{
            return quantity
        }
    }
}
