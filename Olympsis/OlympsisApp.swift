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
    
    @State var showAuth: Bool?
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var notificationManager = NotificationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if showAuth == nil {
                LaunchScreen()
            } else {
                if !showAuth! {
                    ViewContainer() // home view
                        .environmentObject(sessionStore)
                        .environmentObject(notificationManager)
                } else {
                    AuthContainer() // auth view
                        .environmentObject(sessionStore)
                        .environmentObject(notificationManager)
                }
            }
        }.onChange(of: sessionStore.authStatus) { newValue in
            Task {
                await MainActor.run {
                    if sessionStore.authStatus == .authenticated {
                        if showAuth == nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                showAuth = false
                            }
                        } else {
                            DispatchQueue.main.async {
                                showAuth = false
                            }
                        }
                    } else {
                        if showAuth == nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                showAuth = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                showAuth = true
                            }
                        }
                    }
                }
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    
    @AppStorage("deviceToken") private var _token: String?
    let log = Logger(subsystem: "com.josephlabs.olympsis", category: "app_delegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        _token = token;
        log.debug("registered for remote notifications successfull")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.debug("railed to register for remote notifications")
    }
}
