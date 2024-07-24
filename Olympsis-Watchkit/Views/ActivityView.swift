//
//  ActivityView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivityView: View {
    
    var selectedSport: SPORTS
    
    @State private var selected: ACTIVITY_PAGES = .metrics
    @State private var isActive = true
    @State private var countdown: Int = 3
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isLuminanceReduced) var isLuminenceReduced
    @EnvironmentObject private var manager: WorkoutManager
    
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
                .environmentObject(manager)
                .tag(ACTIVITY_PAGES.menu)
            
            switch selectedSport {
            case .running, .walking:
                RunActivityMetrics()
                    .environmentObject(manager)
                    .tag(ACTIVITY_PAGES.metrics)
            case .soccer, .volleyball, .tennis, .spike, .basketball, .football, .pickleball, .racquetball:
                GeneralActivityMetrics()
                    .environmentObject(manager)
                    .tag(ACTIVITY_PAGES.metrics)
            default:
                EmptyView()
            }
            
            switch selectedSport {
            case .running, .walking:
                RunActivityDetails()
                    .environmentObject(manager)
                    .tag(ACTIVITY_PAGES.details)
            case .soccer, .volleyball, .tennis, .spike, .basketball, .football, .pickleball, .racquetball:
                GeneralActivityDetails()
                    .environmentObject(manager)
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
                ZStack(alignment: .center) {
                    Color.colorSecnd
                        .ignoresSafeArea()
                    Text("\(countdown)")
                        .font(.system(size: 150))
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .padding(.bottom)
                    
                }
                .onAppear(perform: startCountdown)
                .zIndex(100)
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
        .environmentObject(WorkoutManager())
}
