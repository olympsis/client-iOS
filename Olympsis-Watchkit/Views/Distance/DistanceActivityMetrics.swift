//
//  DistanceActivityMetrics.swift
//  OlympsisWatchkit
//
//  Created by Joel Joseph on 7/16/25.
//

import SwiftUI

struct DistanceActivityMetrics: View {
    
    @State private var selectedPage: Double = 0.0
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        TabView(selection: $selectedPage) {
            DistanceActivityMetrics1().tag(0.0)
            DistanceActivityMetrics2().tag(1.0)
//            DistanceActivityMetrics3().tag(2.0)
        }
        .tabViewStyle(.verticalPage)
        .digitalCrownRotation(
            $selectedPage,
            from: 0.0,
            through: 2.0,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TimelineView(
                    EllapsedTimeTimelineSchedule(
                        from: manager.builder?.startDate ?? Date()
                    )
                ) { context in
                    HStack {
                        EllaspsedTimeView(ellapsedTime: TimeInterval(manager.builder?.elapsedTime ?? 0), showSubSeconds: context.cadence == .live)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DistanceActivityMetrics()
            .environment(WorkoutManager())
    }
}
