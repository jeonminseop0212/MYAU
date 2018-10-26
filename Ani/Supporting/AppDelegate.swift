//
//  AppDelegate.swift
//  Ani
//
//  Created by 전민섭 on 2018/04/02.
//  Copyright © 2018年 JeonMinseop. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var orientationLock = UIInterfaceOrientationMask.all

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    var firebasePlistName = ""
    
    if IS_DEBUG {
      firebasePlistName = "GoogleService-Info"
    } else {
      firebasePlistName = "GoogleService-Info-release"
    }
    if let path = Bundle.main.path(forResource: firebasePlistName, ofType: "plist"), let firbaseOptions = FirebaseOptions(contentsOfFile: path) {
      FirebaseApp.configure(options: firbaseOptions)
    }
    
    //notification
    application.registerForRemoteNotifications()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = ANITabBarController()
    window?.makeKeyAndVisible()
    
    //navigation bar
    let navigationBarAppearane = UINavigationBar.appearance()
    navigationBarAppearane.barTintColor = .white
    navigationBarAppearane.tintColor = ANIColor.dark
    navigationBarAppearane.setBackgroundImage(UIImage(), for: .default)
    navigationBarAppearane.shadowImage = UIImage()
    
    return true
  }
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return self.orientationLock
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
//    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

//MARK: UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  
  //通知を受け取った時に呼ばれるメソッド
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
//    let userInfo = notification.request.content.userInfo
//
//    if let messageID = userInfo["gcm.message_id"] {
//      DLog("Message ID: \(messageID)")
//    }

    completionHandler([.alert, .badge, .sound])
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    Messaging.messaging().appDidReceiveMessage(userInfo)
    
    completionHandler(.newData)
  }
  
  //通知を開いた時に呼ばれるメソッド
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    
//    let userInfo = response.notification.request.content.userInfo
//
//    if let messageID = userInfo["gcm.message_id"] {
//      DLog("Message ID: \(messageID)")
//    }
    
    completionHandler()
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    UserDefaults.standard.set(fcmToken, forKey: KEY_FCM_TOKEN)
    UserDefaults.standard.synchronize()
  }
  
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
  }
}
