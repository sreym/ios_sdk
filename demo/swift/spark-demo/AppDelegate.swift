//
//  AppDelegate.swift
//  demo
//
//  Created by deploy on 25/01/2018.
//  Copyright © 2018 holaspark. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,
    UNUserNotificationCenterDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        UNUserNotificationCenter.current().delegate = self;
        return true
    }
    
    func application(_ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let parts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data) }
        print("device token: \(parts.joined())")
        // send device token to your APN to be able to receive remote
        // notifications
        // ...
    }
    
    func application(_ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("failed to register for remote notifications: error=\(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler handler:
            @escaping (UNNotificationPresentationOptions) -> Void)
    {
        print("received notification while in foreground")
        handler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let content = response.notification.request.content
        if (content.categoryIdentifier=="spark-preview") {
            print("received notification response with " +
                "\(response.actionIdentifier) for \(content.userInfo)")
            // handle user response on notification request
            // ...
        }
        completionHandler();
    }
}

