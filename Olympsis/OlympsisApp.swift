//
//  OlympsisApp.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import SwiftUI
import Foundation
import UserNotifications
import AuthenticationServices

@main
struct OlympsisApp: App {
    
    @AppStorage("loggedIn") var loggedIn: Bool?
    @StateObject var sessionStore = SessionStore()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var isLoggedIn: Bool {
        guard let log = loggedIn else {
            return false
        }
        return log
    }
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
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
    let log = Logger(subsystem: "com.josephlabs.olympsis", category: "app_delegate")
    @AppStorage("deviceToken") private var _token: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Change this to your preferred presentation option
        completionHandler([[.banner, .badge, .sound]])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        _token = token;
        log.debug("Registered for remote notifications successfull")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.debug("Failed to register for remote notifications")
    }

}
