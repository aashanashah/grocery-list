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
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var coreDataManager: CoreDataManager?
    var managedObjectContext: NSManagedObjectContext?
    let locationManager = CLLocationManager()
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
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
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
    func handleEvent(forRegion region: CLRegion!) {
        // Show an alert if application is active
        
            // Otherwise present a local notification
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
                let repeatAction = UNNotificationAction(identifier:"repeat",
                                                        title:"Repeat",options:[])
                let changeAction = UNTextInputNotificationAction(identifier:
                    "change", title: "Change Message", options: [])
                
                let category = UNNotificationCategory(identifier: "actionCategory",
                                                      actions: [repeatAction, changeAction],
                                                      intentIdentifiers: [], options: [])
                
                content.categoryIdentifier = "actionCategory"
                
                UNUserNotificationCenter.current().setNotificationCategories(
                    [category])
    
        
        
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
            let alert = UIAlertController(title: "enter alert", message: "entered region", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
            let alert = UIAlertController(title: "exit alert", message: "exit successful", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
    {
        let alert = UIAlertController(title: "monitor alert", message: "started monitoring", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

