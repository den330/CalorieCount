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
import  GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    var observer: AnyObject!
    
    func customizeAppearance(){
        let barTintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        UINavigationBar.appearance().barTintColor = barTintColor
        UISearchBar.appearance().barTintColor = barTintColor
        UITabBar.appearance().barTintColor = UIColor.clear
        window!.tintColor = UIColor.white
    }

    func listenForIndexUpdate(){
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: IndexUpdateNotification), object: nil, queue: nil){
            [unowned self] notification in
                self.updateAllRecord()
            }
    }
    

    
    
    func indexAllRecord(){
        if CSSearchableIndex.isIndexingAvailable(){
            let fetchRequest = NSFetchRequest<Day>(entityName: "Day")
            do{
                let context = coreDataStack.context
                let lst = try context.fetch(fetchRequest) 
                let items = lst.map{$0.searchableItem}
                CSSearchableIndex.default().indexSearchableItems(items){error in
                    if let error = error{
                        print("\(error)")
                    }
                }
            }catch{
                print(error)
            }
        }
    }
    
    func updateAllRecord(){
        if CSSearchableIndex.isIndexingAvailable(){
            CSSearchableIndex.default().deleteAllSearchableItems{
                [unowned self] error in
                if let error = error{
                    print(error)
                }else{
                    self.indexAllRecord()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        indexAllRecord()
        customizeAppearance()
        listenForIndexUpdate()
        let TabController = window!.rootViewController as! UITabBarController
        let caloriesController = TabController.viewControllers![0] as! CalorieCountViewController
        let NavController = TabController.viewControllers![1] as! UINavigationController
        let recordController = NavController.topViewController as! RecordTableViewController
        let secondNavController = TabController.viewControllers![2] as! UINavigationController
        let diyController = secondNavController.topViewController as! DIYListViewController
        let thirdNavController = TabController.viewControllers![3] as! UINavigationController
        let favController = thirdNavController.topViewController as! FavViewController
        
        caloriesController.managedContext = coreDataStack.context
        recordController.managedContext = coreDataStack.context
        favController.managedContext = coreDataStack.context
        diyController.managedContext = coreDataStack.context
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9661807512900472~8780399543")
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let objectID: Date
        if userActivity.activityType == CSSearchableItemActionType, let activityObjId = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String{
            objectID = dateFormatter.date(from: activityObjId)!
        }else{
            return false
        }
        let tabCon = window?.rootViewController as! UITabBarController
        tabCon.selectedIndex = 1
        let navCon = tabCon.viewControllers![1] as! UINavigationController
        let dailyCon = navCon.storyboard?.instantiateViewController(withIdentifier: "daily") as! DailyConsumeTableViewController
        dailyCon.managedContext = coreDataStack.context
        do{
            let lst = try coreDataStack.context.fetch(dayFetch)
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


