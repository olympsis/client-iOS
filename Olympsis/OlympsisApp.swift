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

// MARK: - Handle App Setup
class AppDelegate: NSObject, UIApplicationDelegate {
    @AppStorage("deviceToken") private var dToken: String?
    let logger = Logger(subsystem: "com.olympsis.client", category: "app_delegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        StripeAPI.defaultPublishableKey = "pk_test_51P33HvRxf68pt9NZdq8S4g8k8MzQAagKlJVnDyKBejU6lTMaxM6BRq9sMsgtLEriVN6Y3DOQasFJ7oj9Bhr7lh0A00HhrBBrwS"
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

// MARK: - Handle Quick Actions & Universal Links
class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    let logger = Logger(subsystem: "com.olympsis.client", category: "scene_delegate")
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(QuickActionsManager.shared.handleShortcutItem(shortcutItem: shortcutItem))
    }
    
    // MARK: - Universal Links Handler
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        logger.info("Universal link received: \(userActivity.activityType)")
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else {
            logger.warning("Invalid universal link activity")
            return
        }
        
        handleUniversalLink(url: incomingURL)
    }
    
    
    private func handleUniversalLink(url: URL) {
        logger.info("Processing universal link: \(url.absoluteString)")
        
        // Parse the URL path
        let path = url.path
        let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }
        
        print("Universal link path: \(path)")
        print("Path components: \(pathComponents)")
        
        // Handle different URL patterns based on your apple-app-site-association
        if pathComponents.count >= 2 && pathComponents[0] == "events" {
            let eventId = pathComponents[1]
            logger.info("Opening event with ID: \(eventId)")
            print("Event ID: \(eventId)")
            
            // Navigate to event view
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("OpenEvent"),
                    object: nil,
                    userInfo: ["eventId": eventId]
                )
            }
        } else {
            logger.info("Universal link path not handled: \(path)")
            print("Universal link path not handled: \(path)")
        }
    }
}

