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
    
//    func removeLeaks(){
//        do{
//            let results = try coreDataStack.context.executeFetchRequest(itemConsumedFetch)
//            for i in results{
//                let item = i as! ItemConsumed
//                if item.days == nil{
//                    coreDataStack.context.deleteObject(item)
//                }
//            }
//            
//            do{
//                try coreDataStack.context.save()
//            }catch let error as NSError{
//                print("Could not save delete: \(error)")
//            }
//        }catch{
//            print(error)
//        }
//    }
    

    
    
    func indexAllRecord(){
        let fetchRequest = NSFetchRequest(entityName: "Day")
        do{
            let context = coreDataStack.context
            let lst = try context.executeFetchRequest(fetchRequest) as! [Day]
            let items = lst.map{$0.searchableItem}
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(items){error in
                if let error = error{
                    print("\(error)")
                }
            }
            do{
                try coreDataStack.context.save()
            }catch{
                print(error)
            }
        }catch{
            print(error)
        }
    }
    

    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        customizeAppearance()
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
        indexAllRecord()
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        indexAllRecord()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        indexAllRecord()
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        let objectID: NSDate
        if userActivity.activityType == CSSearchableItemActionType, let activityObjId = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String{
            
            objectID = dateFormatter.dateFromString(activityObjId)!
            
        }else{
            return false
        }
        let tabCon = window?.rootViewController as! UITabBarController
        tabCon.selectedIndex = 1
        let navCon = tabCon.viewControllers![1] as! UINavigationController
        let dailyCon = navCon.storyboard?.instantiateViewControllerWithIdentifier("daily") as! DailyConsumeTableViewController
        dailyCon.managedContext = coreDataStack.context
        do{
            let lst = try coreDataStack.context.executeFetchRequest(daysFetch) as! [Day]
            for rday in lst{
                if sameDay([rday], day: objectID){
                    dailyCon.day = rday
                    break
                }
            }
            if dailyCon.day == nil{
                return false
            }
        }catch{
            print(error)
        }
        navCon.pushViewController(dailyCon, animated: true)
        return true
    }
}


