//
//  ItemConsumed+CoreDataProperties.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/15.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ItemConsumed {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var quantityConsumed: NSNumber?
    @NSManaged var totalCalories: NSNumber?
    @NSManaged var unitCalories: NSNumber?
    @NSManaged var quantity: String?
    @NSManaged var brand: String?
    @NSManaged var days: Day?

}
