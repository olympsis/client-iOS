//
//  OlympsisApp.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import TipKit
import SwiftUI
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import UserNotifications
import AuthenticationServices

@main
struct OlympsisApp: App {
    
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    @StateObject private var sessionStore = SessionStore()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            switch authStatus {
            case .unknown, .none:
                LaunchScreen()
            case .authenticated:
                ViewContainer()
                    .environmentObject(sessionStore)
            case .unauthenticated, .not_finished:
                AuthContainer()
                    .environmentObject(sessionStore)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    @AppStorage("deviceToken") private var _token: String?
    let log = Logger(subsystem: "com.olympsis.client", category: "app_delegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        return true
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        _token = token;
        Messaging.messaging().apnsToken = deviceToken
        log.info("Registering for remote notifications successfull")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error("Failed to register for remote notifications")
    }
}
