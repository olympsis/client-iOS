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
                case .running:
                    RunActivityPreperation()
                        .environmentObject(manager)
                        .tag(0)
                default:
                    EmptyView()
                }
                ActivityPreparationSettings(sport: sport)
                    .environmentObject(manager)
                    .tag(1)
            }
        }
    }
}

#Preview {
    ActivityPreparationView(sport: .running)
        .environmentObject(ActivityManager())
}
