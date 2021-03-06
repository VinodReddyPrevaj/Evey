

//
//  AppDelegate.swift
//  EveyDemo
//
//  Created by PROJECTS on 26/09/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dt = String()
    var previousBeacon = String()
    var HallwayBeacon = String()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
        UserDefaults.standard.set([], forKey: "CaresArray")
        UserDefaults.standard.set("", forKey: "Came From")
        UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")
        UserDefaults.standard.set("true", forKey: "Status")

        Thread.sleep(forTimeInterval: 3.0)
        window = UIWindow(frame: UIScreen.main.bounds)
        let credentials: UserDefaults? = UserDefaults.standard
        if !(credentials?.bool(forKey: "checking") ?? false) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "TermsAndConditionsHomeViewController")
            window?.rootViewController = viewController
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "WakeUpViewController") 
            window?.rootViewController = viewController
        }
        
        let touchposeApplication = application as? QTouchposeApplication
        touchposeApplication?.alwaysShowTouches = true
        touchposeApplication?.customTouchImage = UIImage(named: "icon6")
        touchposeApplication?.customTouchPoint = CGPoint(x: 20, y: 20)
      
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {  
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        return true
    }
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")

        print("My token \(deviceToken)")
        var device: String = deviceToken.description
        device = device.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        device = device.replacingOccurrences(of: " ", with: "")
        dt = device
        print("device \(device)")

    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        let str = "\(error)"
        print("Notification Error is \(str)")

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


}

