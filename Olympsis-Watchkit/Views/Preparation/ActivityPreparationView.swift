//
//  ActivityPreperationView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/21/24.
//

import SwiftUI

struct ActivityPreparationView: View {
    
    var sport: SPORTS
    @State private var selected: Int = 0
    @EnvironmentObject private var manager: ActivityManager
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selected) {
                switch sport {
                case .running, .walking:
                    RunActivityPreperation()
                        .environmentObject(manager)
                        .tag(0)
                case .soccer, .volleyball, .tennis, .spike, .basketball, .football, .pickleball, .racquetball:
                    GeneralActivityPreparation(sport: sport)
                        .environmentObject(manager)
                        .tag(0)
                default:
                    EmptyView()
                }
                ActivityPreparationSettings(sport: sport)
                    .environmentObject(manager)
                    .tag(1)
            }.task {
                manager.selectedSport = sport
            }
        }
    }
}

#Preview {
    ActivityPreparationView(sport: .running)
        .environmentObject(ActivityManager())
}
