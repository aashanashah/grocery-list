//
//  AppDelegate.swift
//  Grocery List
//
//  Created by Aashana Shah on 11/6/17.
//  Copyright © 2017 Aashana Shah. All rights reserved.
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
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var coreDataManager: CoreDataManager?
    var managedObjectContext: NSManagedObjectContext?
    let locationManager = CLLocationManager()
    let options: UNAuthorizationOptions = [.alert, .sound, .badge];
    let requestIdentifier = "SampleRequest"
    let center = UNUserNotificationCenter.current()
    var name = ""
    
    //MARK:    Application Life Cycle
    
    //Function that sets navigation for the flow from the main viewController, sets db and asks users for permission
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // For use in foreground
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let nav = UINavigationController(rootViewController: homeViewController)
        appdelegate.window!.rootViewController = nav
        coreDataManager = CoreDataManager(modelName: "Grocery")
        managedObjectContext = coreDataManager?.managedObjectContext
        GMSPlacesClient.provideAPIKey("AIzaSyBSdPfzt7bGUu2u5JaH3xig-DzhnXSGGWU")
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
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
        let snoozeAction = UNNotificationAction(identifier: "Show",
                                                title: "Show", options: [UNNotificationActionOptions.foreground])
        let deleteAction = UNNotificationAction(identifier: "Delete",
                                                title: "Delete", options: [.destructive])
        
        
        
        let category = UNNotificationCategory(identifier: "Actions",
                                              actions: [snoozeAction,deleteAction],
                                              intentIdentifiers: [], options: [])
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.setNotificationCategories([category])
        let content = UNMutableNotificationContent()
        content.title = "Grocery List"
        content.body = "Your list \(region.identifier) is ready. Enjoy Shopping!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "Actions"
        name = region.identifier
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0,
                                                        repeats: false)
        
        
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
    }

    //Function called when user enters the region within a specific radius
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    //Function called when user exits the region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
        }
    }
    
    //Function that starts monitoring the registered region
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started")
    }
    
    //Function that notifies the entry of user in the registered region
    func userNotificationCenter(_
        center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert,.sound,.badge])
    }
    
    // Function that displays options for notification
    func userNotificationCenter(_
        center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        // Determine the user action
        switch response.actionIdentifier {
            case UNNotificationDismissActionIdentifier:
                print("Dismiss Action")
            case UNNotificationDefaultActionIdentifier:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationViewController = storyboard.instantiateViewController(withIdentifier: "ListItemsViewController") as! ListItemsViewController
                let navigationController = self.window?.rootViewController as! UINavigationController
                destinationViewController.name = name
                destinationViewController.flag = 1
                navigationController.pushViewController(destinationViewController, animated: true)
                print("Default")
            case "Show":
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let destinationViewController = storyboard.instantiateViewController(withIdentifier: "ListItemsViewController") as! ListItemsViewController

                let navigationController = self.window?.rootViewController as! UINavigationController
                destinationViewController.name = name
                destinationViewController.flag = 1
                navigationController.pushViewController(destinationViewController, animated: true)
                print("Show")
            case "Delete":
                print("Delete")
            default:
                print("Unknown action")
        }
        completionHandler()
    }
    
}

