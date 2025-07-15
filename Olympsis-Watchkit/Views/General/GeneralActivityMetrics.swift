//
//  GeneralActivityMetrics.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/21/24.
//

import SwiftUI

struct GeneralActivityMetrics: View {
    
    @AppStorage("selected_face") private var selectedFace: Int?
    @Environment(WorkoutManager.self) private var manager
    
    private var averagePaceText: Text {
        let mins = Double(manager.builder?.elapsedTime ?? 0) / 60
        if manager.unit == UnitLength.kilometers {
            let conversion = (manager.distance / 1000)
            return Text("\(mins/conversion, specifier: "%.2f")")
        } else {
            return Text("\(mins/manager.distance, specifier: "%.2f")")
        }
    }
    
    private var distanceText: Text {
        if manager.unit == UnitLength.kilometers {
            let conversion = (manager.distance / 1000)
            return Text("\(conversion, specifier: "%.2f")")
        } else {
            return Text("\(manager.distance, specifier: "%.2f")")
        }
    }
    
    private var caloriesText: Text {
//        return Text(
//            Measurement (
//                value: manager.activeEnergy,
//                unit: UnitEnergy.kilocalories
//            ).formatted(
//                .measurement (
//                    width: .abbreviated,
//                    usage: .workout
//                )
//            )
//        )
        return Text(
            manager.activeEnergy.formatted(
                .number.precision(.fractionLength(0))
            )
        )
        .font(.title2)
        .fontWeight(.semibold)
    }
    
    private var distanceMetric: Text {
        if manager.unit == UnitLength.kilometers {
            return Text("KILOMETERS")
        } else {
            return Text("MILES")
        }
    }
    
    var body: some View {
        VStack {
            VStack(spacing: -5) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.red)
                
                Text(
                    manager.heartRate.formatted(
                        .number.precision(.fractionLength(0))
                    )
                )
                .font(.system(size: 70))
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            }.padding(.vertical)
            
            HStack {
                VStack(spacing: -5) {
                    distanceText
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    distanceMetric
                        .font(.caption2)
                        .foregroundStyle(.primary)
                }

                Spacer()
                
                VStack(spacing: -5) {
                    caloriesText
                        .font(.title2)
                    
                    Text("CALORIES")
                        .font(.caption2)
                }
            }
            .padding(.horizontal)
            .foregroundStyle(.primary)
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
        GeneralActivityMetrics()
            .environment(WorkoutManager())
    }
}
