//
//  DistanceActivityMetrics.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct DistanceActivityMetrics: View {
    
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
            let distanceInMiles = manager.distance / 1609.344
            paceInMinutes = totalMinutes / distanceInMiles
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
            return Text("KILOMETERS")
        } else {
            return Text("MILES")
        }
    }
    
    var body: some View {
        VStack {
            
            Spacer()
            
            VStack(spacing: -10) {
                distanceText
                    .foregroundStyle(Color.Brand.tertiary)
                    .font(.custom("Archivo-Black", size: 70))
                    .fontWeight(.bold)
                
                distanceMetric
                    .textCase(.uppercase)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            Spacer()
            
            TimelineView(
                PaceTimelineSchedule(from: manager.builder?.startDate ?? Date())
            ) { _ in
                HStack {
                    VStack {
                        averagePaceText
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("pace")
                            .textCase(.uppercase)
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    VStack {
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
                                .imageScale(.large)
                        }
                        Text("bpm")
                            .textCase(.uppercase)
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }.padding(.horizontal)
            }
        }.toolbar {
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

private struct EllapsedTimeTimelineSchedule: TimelineSchedule {
    var startDate: Date

    init(from startDate: Date) {
        self.startDate = startDate
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(
            from: self.startDate,
            by: (mode == .lowFrequency ? 1.0 : (1.0 / 30.0))
        ).entries(
            from: startDate,
            mode: mode
        )
    }
}

private struct PaceTimelineSchedule: TimelineSchedule {
    var startDate: Date
    
    init(from startDate: Date) {
        self.startDate = startDate
    }
    
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(
            from: self.startDate,
            by: (mode == .lowFrequency ? 60 : 30)
        ).entries(
            from: startDate,
            mode: mode
        )
    }
}

#Preview {
    NavigationStack {
        DistanceActivityMetrics()
            .environment(WorkoutManager())
    }
}
