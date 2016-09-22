//
//  CoreDataStack.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/14.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack{
    
    let modelName = "Daily Calories"
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    fileprivate lazy var psc: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(self.modelName)
        do{
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption:true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        }catch{
            print("Error adding persistent store")
        }
        return coordinator
    }()
    
    lazy var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.psc
        return managedObjectContext
    }()
    
    func saveContext(){
        if context.hasChanges{
            do{
                try context.save()
            }catch let error as NSError{
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
}
