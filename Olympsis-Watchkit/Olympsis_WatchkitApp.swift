//
//  Olympsis_WatchkitApp.swift
//  Olympsis-Watchkit Watch App
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

@main
struct Olympsis_WatchkitApp: App {
    
    @State private var manager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            ActivityHomeView()
                .environment(manager)
                .task {
                    await manager.fetchWorkoutsHistory(in: manager.weekPredicate.predicateFormat)
                }
                .sheet(isPresented: $manager.showingSummaryView, content: {
                    ActivitySummaryView()
                        .environment(manager)
                })
        }
    }
}
