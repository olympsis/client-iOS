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
            return Text("\(conversion, specifier: "%.2f") km")
        } else {
            return Text("\(manager.distance, specifier: "%.2f") mi")
        }
    }
    
    var body: some View {
        VStack {
            distanceText
            .font(.system(size: 55))
            .fontWeight(.semibold)
            
            Text("distance")
                .textCase(.uppercase)
                .font(.caption)
                .foregroundStyle(.gray)
            
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
                            .font(.title2)
                            .fontWeight(.semibold)
                            
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                                .imageScale(.large)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            
            TimelineView(
                EllapsedTimeTimelineSchedule(
                    from: manager.builder?.startDate ?? Date()
                )
            ) { context in
                HStack {
                    EllaspsedTimeView(ellapsedTime: TimeInterval(manager.builder?.elapsedTime ?? 0), showSubSeconds: context.cadence == .live)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Image(systemName: "clock")
                        .foregroundStyle(Color.colorPrime)
                        .imageScale(.large)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 5)
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
    RunActivityMetrics()
        .environmentObject(ActivityManager())
}
