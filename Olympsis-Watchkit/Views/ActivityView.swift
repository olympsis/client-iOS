//
//  ActivityView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivityView: View {
    
    var selectedSport: SPORTS
    @State var selected: ACTIVITY_PAGES = .metrics
    
    @State private var countdown: Int = 3
    @State private var isActive: Bool = true
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isLuminanceReduced) var isLuminenceReduced
    @EnvironmentObject private var manager: ActivityManager
    
    func startCountdown() {
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
            RunActivityMenu(selection: $selected)
                .environmentObject(manager)
                .tag(ACTIVITY_PAGES.menu)
            
            RunActivityMetrics()
                .environmentObject(manager)
                .tag(ACTIVITY_PAGES.metrics)
            
            RunActivityDetails()
                .environmentObject(manager)
                .tag(ACTIVITY_PAGES.details)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode:  isLuminenceReduced ? .never : .automatic))
        .navigationBarBackButtonHidden()
        .toolbar(.hidden)
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
                    
                }.onAppear(perform: startCountdown)
            }
        }
        .onChange(of: manager.state, { oldValue, newValue in
            if newValue == .ended {
               dismiss()
            }
        })
        .task {
            if manager.session == nil {
                manager.buildWorkout(.running, location: .outdoor)
            } else {
                manager.resumeWorkout()
            }
        }
    }
}

#Preview {
    ActivityView(selectedSport: .running)
        .environmentObject(ActivityManager())
}
