//
//  AppDelegate.swift
//  CalorieCount
//
//  Created by Yaxin Yuan on 16/5/11.
//  Copyright © 2016年 Yaxin Yuan. All rights reserved.
//

import UIKit
import CoreData

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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        customizeAppearance()
        if NSUserDefaults.standardUserDefaults().objectForKey("isFirstTime") == nil{
            removeLeaks()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isFirstTime")
        }
        let TabController = window!.rootViewController as! UITabBarController
        let caloriesController = TabController.viewControllers![0] as! CalorieCountViewController
        let NavController = TabController.viewControllers![1] as! UINavigationController
        let recordController = NavController.topViewController as! RecordTableViewController
        let secondNavController = TabController.viewControllers![2] as! UINavigationController
        let statisticController = secondNavController.topViewController as! StatisticTableViewController
        statisticController.managedContext = coreDataStack.context
        caloriesController.managedContext = coreDataStack.context
        recordController.managedContext = coreDataStack.context
        return true
    }
}

