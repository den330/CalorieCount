//
//  ItemConsumed+CoreDataProperties.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/6/12.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ItemConsumed {

    @NSManaged var brand: String?
    @NSManaged var id: String
    @NSManaged var name: String?
    @NSManaged var quantity: String?
    @NSManaged var quantityConsumed: Int32
    @NSManaged var totalCalories: Double
    @NSManaged var unitCalories: Double
    @NSManaged var isFav: Bool
    @NSManaged var days: Day?

}
