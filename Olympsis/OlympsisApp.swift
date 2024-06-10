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
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        return true
    }
}
