//
//  DistanceActivityMetrics2.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/11/25.
//

import SwiftUI

struct DistanceActivityMetrics2: View {
    
    @Environment(WorkoutManager.self) private var manager
    
    var averagePaceText: Text {
        let totalMinutes = Double(manager.builder?.elapsedTime ?? 0) / 60
        
        // Guard against zero or very small distances
        guard manager.distance > 0.001 else {
            return Text("--:--")
        }
        
        let paceInMinutes: Double
        
        if manager.unit == UnitLength.kilometers {
            let distanceInKm = manager.distance / 1000
            paceInMinutes = totalMinutes / distanceInKm
        } else {
            paceInMinutes = totalMinutes / manager.distance
        }
        
        // Guard against infinite or NaN values
        guard paceInMinutes.isFinite && !paceInMinutes.isNaN else {
            return Text("--:--")
        }
        
        let minutes = Int(paceInMinutes)
        let seconds = Int((paceInMinutes - Double(minutes)) * 60)
        
        return Text(String(format: "%d:%02d", minutes, seconds))
    }
    
    var distanceText: Text {
        if manager.unit == UnitLength.kilometers {
            let conversion = (manager.distance / 1000)
            return Text("\(conversion, specifier: "%.2f")")
        } else {
            return Text("\(manager.distance, specifier: "%.2f")")
        }
    }
    
    var distanceMetricPer: Text {
        if manager.unit == UnitLength.kilometers {
            return Text("/km")
        } else {
            return Text("/mi")
        }
    }
    
    var distanceMetric: Text {
        if manager.unit == UnitLength.kilometers {
            return Text("km")
        } else {
            return Text("mi")
        }
    }
    
    var activeCalories: Text {
        guard manager.activeEnergy > 0 else {
            return Text("--")
        }
        
        return Text("\(manager.activeEnergy, specifier: "%.0f")")
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ZoneViewer(zone: manager.zone)
            
            Spacer()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                TimelineView (
                    PaceTimelineSchedule(from: manager.builder?.startDate ?? Date())
                ) { _ in
                    HStack {
                        distanceText
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        distanceMetric
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                }
                
                TimelineView(
                    PaceTimelineSchedule(from: manager.builder?.startDate ?? Date())
                ) { _ in
                    HStack {
                        Text(
                            manager.heartRate.formatted(
                                .number.precision(.fractionLength(0))
                            )
                        )
                        .font(.title3)
                        .fontWeight(.semibold)
                        
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                            .imageScale(.medium)
                    }
                }
                
                TimelineView (
                    PaceTimelineSchedule(from: manager.builder?.startDate ?? Date())
                ) { _ in
                    HStack {
                        activeCalories
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Cal")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                }
                
                
                TimelineView(
                    PaceTimelineSchedule(from: manager.builder?.startDate ?? Date())
                ) { _ in
                    HStack {
                        averagePaceText
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        distanceMetricPer
                            .font(.headline)
                            .foregroundStyle(.gray)
                        
                    }
                }
                

            }
        }
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
        DistanceActivityMetrics2()
            .environment(WorkoutManager())
    }
}

