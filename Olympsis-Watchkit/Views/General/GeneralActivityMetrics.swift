//
//  GeneralActivityMetrics.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/21/24.
//

import SwiftUI

struct GeneralActivityMetrics: View {
    
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
    
    private var activeCalories: Text {
        guard manager.activeEnergy > 0 else {
            return Text("--")
        }
        
        return Text("\(manager.activeEnergy, specifier: "%.0f")")
    }
    
    private var distanceMetric: Text {
        if manager.unit == UnitLength.kilometers {
            return Text("KILOMETERS")
        } else {
            return Text("MILES")
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack() {
                Image(systemName: "flame.fill")
                    .resizable()
                    .frame(width: 35, height: 40)
                    .foregroundStyle(Color.Brand.tertiary)
                
                activeCalories
                    .minimumScaleFactor(0.7)
                    .font(.custom("Archivo-BlackItalic", size: 70))
                    .fontWeight(.bold)
            }.padding(.vertical)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                TimelineView(
                    PaceTimelineSchedule(from: manager.builder?.startDate ?? Date())
                ) { _ in
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
                                .imageScale(.medium)
                        }
                        
                        Text("BPM")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                }
                
                TimelineView (
                    PaceTimelineSchedule(from: manager.builder?.startDate ?? Date())
                ) { _ in
                    VStack {
                        distanceText
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        distanceMetric
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
        GeneralActivityMetrics()
            .environment(WorkoutManager())
    }
}
