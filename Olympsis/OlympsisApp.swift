//
//  OlympsisApp.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import UIKit
import TipKit
import SwiftUI
import Foundation
import FirebaseCore
import FirebaseAuth
import UserNotifications
import StripePaymentSheet
import AuthenticationServices

@main
struct OlympsisApp: App {
    
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    @State private var sessionStore = SessionStore()
    @StateObject private var quickActionsManager = QuickActionsManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            // An outage outranks the auth state: being offline says nothing
            // about whether the user is signed in, and the sign-in screen is
            // useless without a network anyway.
            if let outage = sessionStore.outage {
                OutageScreen(kind: outage)
                    .environment(sessionStore)
            } else {
                switch authStatus {
                case .unknown, .none:
                    LaunchScreen()
                        .environment(sessionStore)
                case .fatal_error:
                    FatalScreen()
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
}

// MARK: - Handle App Setup
class AppDelegate: NSObject, UIApplicationDelegate {
    @AppStorage("deviceToken") private var dToken: String?
    let logger = Logger(subsystem: "com.olympsis.client", category: "app_delegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        StripeAPI.defaultPublishableKey = AppEnvironment.current.stripePublishableKey
        QuickActionsManager.shared.setupShortcuts()

        // Register the notification delegate at launch so a tap that
        // cold-launches the app is delivered to `didReceive` (which builds
        // the deep link). Without this the delegate is only set lazily when
        // the UI first touches `NotificationManager.shared`, which can miss
        // the launch tap.
        UNUserNotificationCenter.current().delegate = NotificationManager.shared

        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            _ = QuickActionsManager.shared.handleShortcutItem(shortcutItem: shortcutItem)
        }
        
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self
        return sceneConfiguration
    }
}

// MARK: - Handle Notifications Handling
extension AppDelegate : UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        dToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined();
        logger.info("Registering for remote notifications successful.")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }
}

// MARK: - Handle Quick Actions
class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    let logger = Logger(subsystem: "com.olympsis.client", category: "scene_delegate")
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(QuickActionsManager.shared.handleShortcutItem(shortcutItem: shortcutItem))
    }
}

