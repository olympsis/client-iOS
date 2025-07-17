//
//  ActivityView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivityView: View {
    
    var selectedSport: SUPPORTED_SPORTS
    
    @State private var selected: ACTIVITY_PAGES = .metrics
    @State private var isActive = true
    @State private var countdown: Int = 3
    
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutManager.self) private var manager
    @Environment(\.isLuminanceReduced) private var isLuminenceReduced
    
    private func startCountdown() {
        if manager.session == nil {
            manager.prepareWorkout()
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if countdown > 1 {
                    countdown -= 1
                } else {
                    isActive = false
                    timer.invalidate()
                    Task {
                        await manager.startWorkout()
                    }
                }
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selected) {
            
            ActivityMenu(selection: $selected)
                .environment(manager)
                .tag(ACTIVITY_PAGES.menu)
            
            switch selectedSport {
            case .running, .walking:
                DistanceActivityMetrics1()
                    .environment(manager)
                    .tag(ACTIVITY_PAGES.metrics)
            case .soccer, .volleyball, .tennis, .spike, .basketball, .football, .pickleball, .racquetball:
                GeneralActivityMetrics()
                    .environment(manager)
                    .tag(ACTIVITY_PAGES.metrics)
            default:
                EmptyView()
            }
            
            switch selectedSport {
            case .running, .walking:
                DistanceActivityDetails()
                    .environment(manager)
                    .tag(ACTIVITY_PAGES.details)
            case .soccer, .volleyball, .tennis, .spike, .basketball, .football, .pickleball, .racquetball:
                GeneralActivityDetails()
                    .environment(manager)
                    .tag(ACTIVITY_PAGES.details)
            default:
                EmptyView()
            }
            
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode:  isLuminenceReduced ? .never : .automatic))
        .navigationBarBackButtonHidden()
        .toolbar(isActive ? .hidden : .visible)
        .overlay {
            if isActive {
                ActivityCountdownView(isActive: $isActive)
            }
        }
        .onChange(of: manager.state, { oldValue, newValue in
            if newValue == .ended {
               dismiss()
            }
        })
        .task {
            if manager.session == nil {
                manager.buildWorkout(selectedSport.getWorkoutActivityType(), location: .outdoor)
            } else {
                manager.resumeWorkout()
            }
        }
    }
}

#Preview {
    ActivityView(selectedSport: .soccer)
        .environment(WorkoutManager())
}
