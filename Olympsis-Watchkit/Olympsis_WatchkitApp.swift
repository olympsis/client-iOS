//
//  Olympsis_WatchkitApp.swift
//  Olympsis-Watchkit Watch App
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

@main
struct Olympsis_WatchkitApp: App {
    
    @StateObject private var manager = ActivityManager()
    
    var body: some Scene {
        WindowGroup {
            ActivityHomeView()
                .environmentObject(manager)
                .sheet(isPresented: $manager.showingSummaryView, content: {
                    ActivitySummaryView()
                        .environmentObject(manager)
                })
        }
    }
}
