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
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ActivityHistoryView()
                .environment(manager)
                .tag(0)
            ActivitySportsPicker()
                .environment(manager)
                .tag(1)
            ActivitySettingsView()
                .environment(manager)
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
        .environment(WorkoutManager())
}
