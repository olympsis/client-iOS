//
//  RunningActivityView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/7/24.
//

import SwiftUI

struct RunningActivityView: View {
    
    @State var tabs: WORKOUT_TABS = .metrics
    @EnvironmentObject private var session: SessionStore
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        TabView(selection: $tabs) {
            RunningSettingsView(
                selectedTab: $tabs
            )
            .tag(WORKOUT_TABS.settings)
            .environmentObject(session)
            .environmentObject(session.workoutManager)
            
            RunningMetricsView(
                tab: $tabs
            )
            .tag(WORKOUT_TABS.metrics)
            .environmentObject(session)
            .environmentObject(session.workoutManager)
            
            RunningAdvancedMetricsView(
                selectedTab: $tabs
            )
            .tag(WORKOUT_TABS.advanced_metrics)
            .environmentObject(session)
            .environmentObject(session.workoutManager)
        }
    }
}

#Preview {
    let session = SessionStore()
    session.workoutManager.workoutState = .active
    return RunningActivityView()
        .environmentObject(session)
}
