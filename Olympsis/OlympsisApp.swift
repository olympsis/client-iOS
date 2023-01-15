//
//  OlympsisApp.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
struct OlympsisApp: App {
    
    @AppStorage("loggedIn") var loggedIn: Bool?
    @StateObject var sessionStore = SessionStore()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if let _ = loggedIn {
                ViewContainer() // home view
                    .environmentObject(sessionStore)
            } else {
                AuthContainer() // auth view
                    .environmentObject(sessionStore)
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    let log = Logger()
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Change this to your preferred presentation option
        completionHandler([[.banner, .badge, .sound]])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        log.debug("Registered for remote notifications successfull")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.debug("Failed to register for remote notifications")
    }

}
