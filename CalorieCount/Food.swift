//
//  Food.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation

class Food: FoodProtocol{
    var caloriesCount: Double = 0.0
    var foodContent: String = ""
    var brandContent: String = ""
    var quantity: Double = 0.0
    var unit: String = ""
    var id: String = ""
    
    var foodProId: String{
        get{
            return id
        }
    }
    
    var foodProBrand: String{
        get{
            return brandContent
        }
    }
    
    var foodProCalorie: Double{
        get{
            return caloriesCount
        }
    }
    
    var foodProContent: String{
        get{
            return foodContent
        }
    }
    
    var foodProUnit: String{
        get{
            let foodUnit = String(quantity) + " " + unit
            return foodUnit
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
