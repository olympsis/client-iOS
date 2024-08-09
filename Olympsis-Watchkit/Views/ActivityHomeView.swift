//
//  HomeView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI
import CoreLocation

struct ActivityHomeView: View {
    
    @State private var selectedTab: Int = 1
    @EnvironmentObject private var manager: WorkoutManager
    
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
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .task {
            let location = CLLocationManager()
            location.requestWhenInUseAuthorization()
            await manager.requestHealthStoreAuthorization()
        }
    }
}

#Preview {
    ActivityHomeView()
        .environmentObject(WorkoutManager())
}
