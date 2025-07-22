//
//  ActivityPreperationView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/21/24.
//

import SwiftUI

struct ActivityPreparationView: View {
    
    var sport: SUPPORTED_SPORTS
    @State private var selected: Int = 0
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        Group {
            switch sport {
            case .running, .walking:
                DistanceActivityPreparation(sport: sport)
                    .environment(manager)
                    .tag(0)
            default:
                GeneralActivityPreparation(sport: sport)
                    .environment(manager)
                    .tag(0)
            }
        }.task {
            manager.selectedSport = sport
        }
    }
}

#Preview {
    ActivityPreparationView(sport: .running)
        .environment(WorkoutManager())
}
