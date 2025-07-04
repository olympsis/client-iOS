//
//  WorkoutSplitDetails.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/25/25.
//

import Charts
import SwiftUI
import HealthKit

struct WorkoutStatistics: View {
    let workout: Workout
    
    private var heartRateChartData: [(Date, Double)] {
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        return workout.heartSamples.map { sample in
            (sample.startDate, sample.quantity.doubleValue(for: heartRateUnit))
        }
    }
    
    private var distanceChartData: [(Date, Double)] {
        let meterUnit = HKUnit.meter()
        var cumulativeDistance: Double = 0
        return workout.distanceSamples.map { sample in
            cumulativeDistance += sample.quantity.doubleValue(for: meterUnit)
            return (sample.startDate, cumulativeDistance / 1000) // Convert to kilometers
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Heart Rate Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Heart Rate")
                        .font(.custom("Archivo-Bold", size: 18))
                        .foregroundColor(.primary)
                    
                    if !heartRateChartData.isEmpty {
                        Chart {
                            ForEach(Array(heartRateChartData.enumerated()), id: \.offset) { index, data in
                                LineMark(
                                    x: .value("Time", data.0),
                                    y: .value("Heart Rate", data.1)
                                )
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(.red)
                                
                                AreaMark(
                                    x: .value("Time", data.0),
                                    y: .value("Heart Rate", data.1)
                                )
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(.red.opacity(0.2))
                            }
                        }
                        .chartYScale(domain:(heartRateChartData.map { $0.1 }.min() ?? 0) - 5...(heartRateChartData.map { $0.1 }.max() ?? 100) + 5)
                        .frame(height: 200)
                        .clipped()
                        
                        
                        // Heart Rate Stats
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Min")
                                    .font(.custom("Archivo-Regular", size: 12))
                                    .foregroundColor(.secondary)
                                Text("\(Int(heartRateChartData.map(\.1).min() ?? 0)) BPM")
                                    .font(.custom("Archivo-Bold", size: 16))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .center) {
                                Text("Average")
                                    .font(.custom("Archivo-Regular", size: 12))
                                    .foregroundColor(.secondary)
                                Text("\(Int(workout.averageHeartRate)) BPM")
                                    .font(.custom("Archivo-Bold", size: 16))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Max")
                                    .font(.custom("Archivo-Regular", size: 12))
                                    .foregroundColor(.secondary)
                                Text("\(Int(heartRateChartData.map(\.1).max() ?? 0)) BPM")
                                    .font(.custom("Archivo-Bold", size: 16))
                            }
                        }
                        .padding(.top, 8)
                    } else {
                        Text("No heart rate data available")
                            .font(.custom("Archivo-Regular", size: 14))
                            .foregroundColor(.secondary)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Distance Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Distance")
                        .font(.custom("Archivo-Bold", size: 18))
                        .foregroundColor(.primary)
                    
                    if !distanceChartData.isEmpty {
                        Chart {
                            ForEach(Array(distanceChartData.enumerated()), id: \.offset) { index, data in
                                LineMark(
                                    x: .value("Time", data.0),
                                    y: .value("Distance", data.1)
                                )
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(.blue)
                                
                                AreaMark(
                                    x: .value("Time", data.0),
                                    y: .value("Distance", data.1)
                                )
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(.blue.opacity(0.2))
                            }
                        }
                        .frame(height: 200)
                        
                        // Distance Stats
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total Distance")
                                    .font(.custom("Archivo-Regular", size: 12))
                                    .foregroundColor(.secondary)
                                Text(String(format: "%.2f km", workout.totalDistance))
                                    .font(.custom("Archivo-Bold", size: 16))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Average Pace")
                                    .font(.custom("Archivo-Regular", size: 12))
                                    .foregroundColor(.secondary)
                                Text(workout.averagePace)
                                    .font(.custom("Archivo-Bold", size: 16))
                            }
                        }
                        .padding(.top, 8)
                    } else {
                        Text("No distance data available")
                            .font(.custom("Archivo-Regular", size: 14))
                            .foregroundColor(.secondary)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        WorkoutStatistics(workout: Workout(type: .running, workout: HKWorkout(activityType: .other, start: Date(), end: Date())))
    }
}
