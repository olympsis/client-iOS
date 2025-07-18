//
//  DistanceActivityMetrics.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct DistanceActivityMetrics1: View {
    
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
    
    var distanceMetric: Text {
        if manager.unit == UnitLength.kilometers {
            return Text("/km")
        } else {
            return Text("/mi")
        }
    }
    
    var distanceMetricLarge: Text {
        if manager.unit == UnitLength.kilometers {
            return Text("KILOMETERS")
        } else {
            return Text("MILES")
        }
    }
    
    var activeCalories: Text {
        guard manager.activeEnergy > 0 else {
            return Text("--")
        }
        
        return Text("\(manager.activeEnergy, specifier: "%.0f")")
    }
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: -10) {
                VStack(alignment: .trailing, spacing: -5) {
                    distanceText
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(Color.Brand.tertiary)
                        .font(.custom("Archivo-BlackItalic", size: 70))
                        .fontWeight(.bold)
                }
                
                distanceMetricLarge
                    .foregroundStyle(.gray)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
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
                
                TimelineView (
                    PaceTimelineSchedule(from: manager.builder?.startDate ?? Date())
                ) { _ in
                    VStack {
                        SmallZoneViewer(zone: manager.zone)
                    }
                }
                
                
                TimelineView(
                    PaceTimelineSchedule(from: manager.builder?.startDate ?? Date())
                ) { _ in
                    HStack {
                        averagePaceText
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
            }
        }
    }
}

#Preview {
    NavigationStack {
        DistanceActivityMetrics1()
            .environment(WorkoutManager())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    TimelineView(
                        EllapsedTimeTimelineSchedule(
                            from: WorkoutManager().builder?.startDate ?? Date()
                        )
                    ) { context in
                        HStack {
                            EllaspsedTimeView(ellapsedTime: TimeInterval(WorkoutManager().builder?.elapsedTime ?? 0), showSubSeconds: context.cadence == .live)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
    }
}
