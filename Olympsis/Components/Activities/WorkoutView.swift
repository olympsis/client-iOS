//
//  WorkoutView.swift
//  Olympsis
//
//  Created by Joel on 10/17/23.
//

import SwiftUI
import HealthKit

struct WorkoutView: View {
    
    var activityName: String
    var workout: Workout
    @State private var state: LOADING_STATE = .loading
    
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutManager.self) private var manager
    
    private var hasSplits: Bool {
        return workout.type == .running || workout.type == .cycling
    }
    
    private var cadence: String {
        guard let cadence = workout.cadence,
              cadence != 0 else {
            return "-"
        }
        return String(format: "%.1f", cadence)
    }
    
    private var splits: [RunSplit] {
        return workout.paceSegments.map {
            RunSplit(id: $0.segmentNumber, pace: $0.pace, elevation: 0)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color.foreground)
                        .overlay {
                            workout.type.icon()
                                .resizable()
                                .frame(width: 45, height: 55)
                                .foregroundStyle(Color.Background.primary)
                        }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("\(workout.totalDistance, specifier: "%0.2f")")
                            .font(.custom("Archivo-BlackItalic", size: 80))
                            .italic()
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .foregroundStyle(Color.foreground)
                        
                        Text("Miles")
                            .foregroundColor(.gray)
                            .padding(.leading)
                    }.padding(.leading)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding([.top, .horizontal])
                
                // MARK: - Workout Details
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(workout.averagePace)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                            Text("Avg. Pace")
                        }.frame(width: 100)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("\(workout.totalCaloriesBurned, specifier: "%.0f")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                            Text("Calories")
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text(workout.totalTime)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.Brand.tertiary)
                            Text("Time")
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 25)
                        
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(workout.averageHeartRate, specifier: "%.0f")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.Brand.secondary)
                            Text("Avg. Heart Rate")
                        }
                        .frame(width: 100)
                        .redacted(reason: state == .loading ? .placeholder : [])
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text(cadence)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.Brand.quaternary)
                            Text("Cadence")
                        }
                        .frame(width: 100)
                        .redacted(reason: state == .loading ? .placeholder : [])
                    }
                    .padding(.horizontal, 25)
                }
                
                // Workout map view
                if !workout.route2DPoints.isEmpty {
                    WorkoutMapView(locations: workout.route2DPoints)
                        .redacted(reason: state == .loading ? .placeholder : [])
                }
                
                // Workout Splits view
                if !splits.isEmpty {
                    WorkoutSplitsView(splits: splits)
                        .padding(.top)
                        .redacted(reason: state == .loading ? .placeholder : [])
                }
                
                // Workout Statistics View
                WorkoutStatistics(workout: workout)
                    .redacted(reason: state == .loading ? .placeholder : [])
            }
            .navigationTitle(activityName)
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            state = .loading
            // Only fetch additional data if we don't already have it
            if workout.cadence == nil || 
               workout.heartSamples.isEmpty || 
               workout.locationSamples.isEmpty || 
               workout.paceSegments.isEmpty {
                
                guard let details = await manager.fetchWorkoutAdditionalData(from: workout.workout) else {
                    state = .failure
                    return
                }
                
                workout.cadence = details.cadence
                workout.locationSamples = details.route
                workout.paceSegments = details.paceSegments
                workout.heartSamples = details.heartRateSamples
            }
//            
//            let stats = workout.workout.allStatistics
//            for stat in stats {
//                print(stat.key)
//                print(stat.key == HKQuantityTypeIdentifier.activeEnergyBurned as NSObject)
//                print(stat.key == HKQuantityTypeIdentifier.distanceWalkingRunning as NSObject)
//            }
            state = .success
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutView(activityName: "Friday Evening Run", workout: Workout(type: .running, workout: HKWorkout(activityType: .running, start: Date(), end: Date().addingTimeInterval(30 * 60))))
            .environment(WorkoutManager())
    }
}
