//
//  HomeView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI
import CoreLocation

struct ViewContainer: View {
    
    @State private var selectedTab: Int = 1
    @Environment(WorkoutManager.self) private var manager
    @Environment(\.isLuminanceReduced) private var isLuminenceReduced
    
    var body: some View {
        NavigationStack {
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
            .tabViewStyle(PageTabViewStyle(indexDisplayMode:  isLuminenceReduced ? .never : .automatic))
            .task {
                let location = CLLocationManager()
                location.requestWhenInUseAuthorization()
//                _ = await manager.requestHealthStoreAuthorization()
            }
        }
    }
}

#Preview {
    ViewContainer()
        .environment(WorkoutManager())
}
