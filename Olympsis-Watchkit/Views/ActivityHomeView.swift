//
//  HomeView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivityHomeView: View {
    
    @State private var selectedTab: Int = 1
    @EnvironmentObject private var manager: ActivityManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ActivityHistoryView()
                .environmentObject(manager)
                .tag(0)
            ActivitySportsPicker()
                .environmentObject(manager)
                .tag(1)
            ActivitySettingsView()
                .environmentObject(manager)
                .tag(2)
        }
        .task {
            await manager.requestHealthStoreAuthorization()
        }
    }
}

#Preview {
    ActivityHomeView()
        .environmentObject(ActivityManager())
}
