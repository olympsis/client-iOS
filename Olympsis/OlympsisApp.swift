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
import UserNotifications
import AuthenticationServices

@main
struct OlympsisApp: App {
    
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    @State private var sessionStore = SessionStore()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            switch authStatus {
            case .unknown, .none:
                LaunchScreen()
                    .environment(sessionStore)
            case .authenticated:
                ViewContainer()
                    .environment(sessionStore)
            case .unauthenticated, .not_finished:
                AuthContainer()
                    .environment(sessionStore)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    @AppStorage("deviceToken") private var dToken: String?
    let log = Logger(subsystem: "com.olympsis.client", category: "app_delegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        return true
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        dToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined();
        log.info("Registering for remote notifications successful.")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error("Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }
}
