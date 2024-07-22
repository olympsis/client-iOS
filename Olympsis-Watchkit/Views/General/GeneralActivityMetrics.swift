//
//  GeneralActivityMetrics.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/21/24.
//

import SwiftUI

struct GeneralActivityMetrics: View {
    
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
    
    var caloriesText: Text {
        return Text(
            Measurement (
                value: manager.activeEnergy,
                unit: UnitEnergy.kilocalories
            ).formatted(
                .measurement (
                    width: .abbreviated,
                    usage: .workout
                )
            )
        )
        .font(.title2)
        .fontWeight(.semibold)
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    
                    Text(
                        manager.heartRate.formatted(
                            .number.precision(.fractionLength(0))
                        )
                    )
                    .font(.system(size: 55))
                    .fontWeight(.semibold)
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.red)
                }
                
                Text("BPM")
            }.padding(.vertical)
            
            distanceText
                .font(.title2)
                .fontWeight(.semibold)

            HStack {
                caloriesText
                
                Image(systemName: "flame")
                    .imageScale(.large)
                    .foregroundStyle(.orange)
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
                }
                .padding(.bottom)
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

#Preview {
    GeneralActivityMetrics()
        .environmentObject(ActivityManager())
}
