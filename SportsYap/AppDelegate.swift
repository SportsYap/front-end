//
//  AppDelegate.swift
//  SportsYap
//
//  Created by Alex Pelletier on 1/29/18.
//  Copyright © 2018 Alex Pelletier. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import FBSDKCoreKit
import IQKeyboardManagerSwift
import Firebase
import OneSignal
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        _ = CacheManager.shared
        _ = ApiManager.shared
        
        //Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [SignupViewController.self]
        
        ApiManager.shared.stopStream(onSuccess: { }, onError: voidErr)

        // setup push notifications
        let notificationRecievedBlock: OSHandleNotificationReceivedBlock = { result in
            
            let payload: OSNotificationPayload? = result?.payload
            
            guard let additionalData = result!.payload!.additionalData else { return }
            print("additionalData = \(additionalData)")
            print("post date is \(additionalData["postDate"])")
            
            if let postDateString = additionalData["postDate"] as? String {
                UserDefaults.standard.set(postDateString, forKey: "reportedPost")
            }
            
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload

            
            print("Message = \(payload!.body)")
            print("badge number = \(payload?.badge ?? 0)")
            print("notification sound = \(payload?.sound ?? "None")")
            
            guard let additionalData = result!.notification.payload!.additionalData else { return }
            print("additionalData = \(additionalData)")
            print("post id is \(additionalData["postId"])")
     
            if let postIdString = additionalData["postId"] as? String {
                let postId = Int(postIdString)
                print("the post id is \(postId)")
                
                if let navigationController = TabBarViewController.sharedInstance.selectedViewController as? UINavigationController {
                    
                    if navigationController.viewControllers.first is HomeViewController {
                        
                        navigationController.viewControllers.first?.performSegue(withIdentifier: "showSinglePost", sender: postId!)
                    }
                }
                
            } else if let userIdString = additionalData["userId"] as? String {
                let userId = Int(userIdString)
                print("the user id is \(userId)")
                
                ApiManager.shared.user(for: userId!, onSuccess: { (user) in
                    
                    if let navigationController = TabBarViewController.sharedInstance.selectedViewController as? UINavigationController {
                        
                        if navigationController.viewControllers.first is HomeViewController {
                            
                            navigationController.viewControllers.first?.performSegue(withIdentifier: "showProfile", sender: user)
                        }
                    }
                    
                }, onError: { (error) in
                    print(error)
                })
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "f123f9dc-1b7c-476d-bf53-07adc6b24628",
                                        handleNotificationReceived: notificationRecievedBlock,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
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
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as! String, annotation: options[.annotation])
        
        return handled
    }
    

}

