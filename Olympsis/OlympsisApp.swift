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
import AuthenticationServices

@main
struct OlympsisApp: App {
    
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    @State private var sessionStore = SessionStore()
    @StateObject private var toastManager = ToastManager()
    @StateObject private var quickActionsManager = QuickActionsManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
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
    let logger = Logger(subsystem: "com.olympsis.client", category: "app_delegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        
        QuickActionsManager.shared.setupShortcuts()
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

extension AppDelegate : UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        dToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined();
        logger.info("Registering for remote notifications successful.")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }
}


class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(QuickActionsManager.shared.handleShortcutItem(shortcutItem: shortcutItem))
    }
}
