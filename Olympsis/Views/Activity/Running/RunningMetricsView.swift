//
//  RunningMetricsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/7/24.
//

import MapKit
import SwiftUI

struct RunningMetricsView: View {
    
    @Binding var tab: WORKOUT_TABS
    
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var manager: WorkoutManager
    
    var body: some View {
        VStack {
            
            RunningMetrics(
                calories: $manager.caloriesBurned,
                time: $manager.ellapsedTime,
                bpm: $manager.heartRate,
                distance: $manager.distanceTraveled
            )
            
            Spacer()
            
            if manager.workoutState != .paused {
                VStack {
                    Text(formatPace(pace: manager.pace))
                        .italic()
                        .fontWeight(.bold)
                        .font(.system(size: 100))
                    
                    Text("avg pace")
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                }
            } else {
                VStack {
                    Text(formatPace(pace: manager.pace))
                        .italic()
                        .fontWeight(.bold)
                        .font(.title)
                    
                    Text("avg pace")
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                }
                
                RunningMap()
                
                RunningSplits(splits: [
                    RunSplit(id: 1, pace: 511, elevation: -3),
                    RunSplit(id: 2, pace: 485, elevation: 10),
                    RunSplit(id: 3, pace: 710, elevation: -30)
                ])
                .padding(.vertical)
            }
            
            Spacer()
            
            RunningActions(selectedTab: $tab)
                .padding(.bottom, 20)
                .environmentObject(manager)
        }
    }
}

#Preview {
    RunningMetricsView(
        tab: .constant(.metrics)
    )
    .environmentObject(SessionStore())
    .environmentObject(WorkoutManager())
}
