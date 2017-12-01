//
//  AppDelegate.swift
//  Grocery List
//
//  Created by Aashana on 11/6/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import SystemConfiguration
import UserNotifications




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coreDataManager: CoreDataManager?
    var managedObjectContext: NSManagedObjectContext?
  
    let options: UNAuthorizationOptions = [.alert, .sound];
    let notificationDelegate = Notification()
    let requestIdentifier = "SampleRequest"
    let center = UNUserNotificationCenter.current()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let nav = UINavigationController(rootViewController: homeViewController)
        appdelegate.window!.rootViewController = nav // For use in foreground
        coreDataManager = CoreDataManager(modelName: "Grocery")
        managedObjectContext = coreDataManager?.managedObjectContext
        GMSPlacesClient.provideAPIKey("AIzaSyBSdPfzt7bGUu2u5JaH3xig-DzhnXSGGWU")
                // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        let content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.body = "Buy some milk"
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0,
                                                        repeats: false)
        
        
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
        let snoozeAction = UNNotificationAction(identifier: "Snooze",
                                                title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete",
                                                title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: "Category",
                                              actions: [snoozeAction,deleteAction],
                                              intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
        content.categoryIdentifier = "Category"
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

