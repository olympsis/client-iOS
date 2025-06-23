//
//  RunningActivitySummary.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI
import HealthKit

struct ActivitySummaryView: View {
    
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var ellapsedTime: Double {
        return Double(manager.workout?.duration ?? 0)
    }
    
    var distanceText: Text {
        if manager.unit == UnitLength.kilometers {
            let distance = manager.workout?.statistics(for:
                HKQuantityType.init(.distanceWalkingRunning))?
                    .sumQuantity()?
                    .doubleValue(for: .meter()) ?? 0
            let conversion = (distance / 1000)
            return Text("\(conversion, specifier: "%.2f") km")
        } else {
            let distance = manager.workout?.statistics(for:
                HKQuantityType.init(.distanceWalkingRunning))?
                    .sumQuantity()?
                    .doubleValue(for: .mile()) ?? 0
            return Text("\(distance, specifier: "%.2f") mi")
        }
    }
    
    var averagePaceText: Text {
        let mins = ellapsedTime/60
        if manager.unit == UnitLength.kilometers {
            let distance = manager.workout?.statistics(for:
                HKQuantityType.init(.distanceWalkingRunning))?
                    .sumQuantity()?
                    .doubleValue(for: .meter()) ?? 0
            let conversion = (distance / 1000)
            return Text("\(mins/conversion, specifier: "%.2f") /km")
        } else {
            let distance = manager.workout?.statistics(for:
                HKQuantityType.init(.distanceWalkingRunning))?
                    .sumQuantity()?
                    .doubleValue(for: .mile()) ?? 0
            return Text("\(mins/distance, specifier: "%.2f") /mi")
        }
    }
    
    var averageHeartRate: Double {
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        return manager.workout?.statistics(for: HKQuantityType.init(.heartRate))?.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
    }
    
    var totalEnergyBurned: Double {
        return manager.workout?.statistics(for: HKQuantityType.init(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        ScrollView {
            VStack {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("Total Time")
                            .font(.caption)
                            .textCase(.uppercase)
                        
                        Text(
                            durationFormatter.string(from: ellapsedTime) ?? ""
                        )
                        .font(.title2)
                        .fontWeight(.semibold)
                    }
                    
                    Image(systemName: "clock")
                        .foregroundStyle(Color.Brand.secondary)
                        .imageScale(.large)
                        .fontWeight(.bold)
                        .padding(.all)
                    
                    Spacer()
                }
                .padding(.bottom)
                
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total distance")
                            .font(.caption)
                            .textCase(.uppercase)
                        
                        distanceText
                        .font(.title2)
                        .fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Avg Pace")
                            .font(.caption)
                            .textCase(.uppercase)
                        
                        averagePaceText
                        .font(.title2)
                        .fontWeight(.semibold)
                    }
                    Spacer()
                }
                
                .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Avg Heart rate")
                            .font(.caption)
                            .textCase(.uppercase)
                        
                        HStack {
                            Text(
                                averageHeartRate.formatted(
                                    .number.precision(.fractionLength(0))
                                )
                            )
                            .font(.title2)
                            .fontWeight(.semibold)
                            
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("Calories Burned")
                            .font(.caption)
                            .textCase(.uppercase)
                        
                        Text(
                            Measurement (
                                value: totalEnergyBurned,
                                unit: UnitEnergy.kilocalories
                            ).formatted(
                                .measurement (
                                    width: .abbreviated,
                                    usage: .workout,
                                    numberFormatStyle: .number
                                )
                            )
                        )
                        .font(.title2)
                        .fontWeight(.semibold)
                    }
                    
                    Image(systemName: "flame")
                        .foregroundStyle(.orange)
                        .imageScale(.large)
                        .padding([.bottom, .horizontal])
                    Spacer()
                }
                .padding(.bottom)
                
                HStack() {
                    VStack(alignment: .leading) {
                        Text("Activity Rings")
                            .font(.caption)
                            .textCase(.uppercase)
                        
                        ActivityRingsView(
                            healthStore: manager.healthStore
                        ).frame(width: 50, height: 50)
                    }
                    
                    Spacer()
                }.padding(.bottom)
                
            }.scenePadding()
            
            
            
            Button(action: {
                manager.resetWorkout()
                dismiss()
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 50)
                    .foregroundStyle(Color.colorPrime)
                    .overlay {
                        Text("Done")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ActivitySummaryView()
            .environment(WorkoutManager())
    }
}
