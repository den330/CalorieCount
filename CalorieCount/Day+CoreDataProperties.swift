//
//  Day+CoreDataProperties.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/14.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Day {
    
    @NSManaged var currentDate: NSDate?
    @NSManaged var items: NSOrderedSet?

}
