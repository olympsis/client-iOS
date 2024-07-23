//
//  ActivitySnapshot.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct RunActivityMetrics: View {
    
    @EnvironmentObject private var manager: ActivityManager
    
    var averagePaceText: Text {
        let mins = Double(manager.builder?.elapsedTime ?? 0) / 60
        if manager.unit == UnitLength.kilometers {
            let conversion = (manager.distance / 1000)
            return Text("\(mins/conversion, specifier: "%.2f")")
        } else {
            return Text("\(mins/manager.distance, specifier: "%.2f")")
        }
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
                    .foregroundStyle(.yellow)
                    .font(.system(size: 70))
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
        RunActivityMetrics()
            .environmentObject(ActivityManager())
    }
}
