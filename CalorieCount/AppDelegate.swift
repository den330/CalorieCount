//
//  AppDelegate.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    
    func customizeAppearance(){
        let barTintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        let tabBarTintColor = UIColor.clearColor()
        let cellColor = UIColor(red: 255, green: 255, blue: 0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = barTintColor
        UISearchBar.appearance().barTintColor = barTintColor
        UITabBar.appearance().barTintColor = tabBarTintColor
        UITableViewCell.appearance().backgroundColor = cellColor
        UITableView.appearance().backgroundColor = cellColor
        window!.tintColor = UIColor.whiteColor()
    }
    
    func removeLeaks(){
        do{
            let results = try coreDataStack.context.executeFetchRequest(itemConsumedFetch)
            for i in results{
                let item = i as! ItemConsumed
                if item.days == nil{
                    coreDataStack.context.deleteObject(item)
                }
            }
            
            do{
                try coreDataStack.context.save()
            }catch let error as NSError{
                print("Could not save delete: \(error)")
            }
        }catch{
            print(error)
        }
    }
    

    
    
    func indexAllRecord(){
        let fetchRequest = NSFetchRequest(entityName: "Day")
        do{
            let lst = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Day]
            let lstReverse = lst.reverse()
            let items = lstReverse.map{$0.searchableItem}
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(items){error in
                if let error = error{
                    print("\(error)")
                }else{
                    print("indexed")
                }
            }
        }catch{
            print(error)
        }
    }
    
    func destroyAllRecord(){
        CSSearchableIndex.defaultSearchableIndex().deleteAllSearchableItemsWithCompletionHandler{
            error in
            if let error = error{
                print(error)
            }else{
                print("deleted index")
            }
        }
    }
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        customizeAppearance()
        if NSUserDefaults.standardUserDefaults().objectForKey("isFirstTime") == nil{
            removeLeaks()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isFirstTime")
        }
        destroyAllRecord()
        indexAllRecord()
        let TabController = window!.rootViewController as! UITabBarController
        let caloriesController = TabController.viewControllers![0] as! CalorieCountViewController
        let NavController = TabController.viewControllers![1] as! UINavigationController
        let recordController = NavController.topViewController as! RecordTableViewController
        let secondNavController = TabController.viewControllers![2] as! UINavigationController
        let statisticController = secondNavController.topViewController as! StatisticTableViewController
        let thirdNavController = TabController.viewControllers![3] as! UINavigationController
        let favController = thirdNavController.topViewController as! FavViewController
        statisticController.managedContext = coreDataStack.context
        caloriesController.managedContext = coreDataStack.context
        recordController.managedContext = coreDataStack.context
        favController.managedContext = coreDataStack.context
        return true
    }
}
    
//    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
//        let objectId: String
//        if userActivity.activityType == CSSearchableItemActionType{
//            if let activityObjectId = userActivity.userInfo![CSSearchableItemActivityIdentifier] as! String{
//                objectId = activityObjectId
//                print(objectId)
//                print(dateFormatter.dateFromString(objectId))
//                return true
//            }else{
//                return false
//            }
//        }else{
//            return false
//        }
//    }
//}

