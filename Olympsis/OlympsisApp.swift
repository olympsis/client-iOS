//
//  OlympsisApp.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import SwiftUI

@main
struct OlympsisApp: App {
    
    @AppStorage("loggedIn") var loggedIn: Bool?
    @StateObject var sessionStore = SessionStore()
    
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
