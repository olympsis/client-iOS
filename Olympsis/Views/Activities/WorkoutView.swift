//
//  WorkoutView.swift
//  Olympsis
//
//  Created by Joel on 10/17/23.
//

import SwiftUI
// import HealthKit
import CoreLocation

struct WorkoutView: View {
    
    var activityName: String
    var workout: Workout
    @State private var state: LOADING_STATE = .loading
    @State private var showHeartDetails: Bool = false
    @State private var workoutLocationString: String? = nil
    @State private var gradientColors: [Color] = [Color.Brand.primary]
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
        return String(format: "%.0f", cadence)
    }
    
    private var elevationGain: String {
        guard workout.totalElevationGain > 0 else {
            return "-"
        }
        return String(format: "%.0f \(manager.unit == .miles ? "ft" : "m")", workout.totalElevationGain)
    }
    
    /// Generates an array of colors matching location points based on heart rate zones
    /// Each color corresponds to the heart rate zone at that location point
    /// - Returns: Array of colors matching the workout.route2DPoints array
    private func generateHeartRateZoneColors() -> [Color] {
        // Return default colors if no heart rate data or location data
        guard !workout.heartSamples.isEmpty && !workout.route2DPoints.isEmpty else {
            return [Color.Brand.primary]
        }
        
        var colors: [Color] = []
        
        // Sort heart rate samples by timestamp for efficient lookup
        let sortedHeartSamples = workout.heartSamples.sorted { $0.startDate < $1.startDate }
        
        // For each location point, find the closest heart rate sample and determine its zone
        for (index, _) in workout.route2DPoints.enumerated() {
            // Calculate timestamp for this location point based on workout progress
            let workoutDuration = workout.workout.duration
            let timeInterval = workoutDuration / Double(workout.route2DPoints.count)
            let pointTimestamp = workout.workout.startDate.addingTimeInterval(timeInterval * Double(index))
            
            // Find the closest heart rate sample to this timestamp
            _ = sortedHeartSamples.min { sample1, sample2 in
                abs(sample1.startDate.timeIntervalSince(pointTimestamp)) < abs(sample2.startDate.timeIntervalSince(pointTimestamp))
            }
            
            /* HealthKit disabled
            if let heartRateSample = closestHeartRateSample {
                // Get heart rate value
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRateValue = heartRateSample.quantity.doubleValue(for: heartRateUnit)

                // Determine zone using WorkoutManager
                let zoneNumber = manager.getZoneFromHeartRate(heartRateValue)

                // Get zone color
                let zoneColor = colorForZone(zoneNumber)
                colors.append(zoneColor)
            } else {
                // Fallback to default color if no heart rate sample found
                colors.append(Color.blue)
            }
            */
            // Fallback: use default color since HealthKit is disabled
            colors.append(Color.blue)
        }
        
        return colors
    }
    
    /// Returns the color for a given heart rate zone number
    /// - Parameter zoneNumber: Zone number (1-5)
    /// - Returns: Color for the zone
    private func colorForZone(_ zoneNumber: Int) -> Color {
        switch zoneNumber {
        case 1: return .blue      // Zone 1: Active Recovery
        case 2: return .green     // Zone 2: Aerobic Base
        case 3: return .yellow    // Zone 3: Aerobic
        case 4: return .orange    // Zone 4: Lactate Threshold
        case 5: return .red       // Zone 5: VO2 Max
        default: return .gray
        }
    }
    
    @MainActor
    private func getWorkoutLocation(coordinate: CLLocation) async -> String? {
        do {
            let geocoder = CLGeocoder()
            let results = try await geocoder.reverseGeocodeLocation(coordinate)
            guard let location = results.first,
                  let city = location.locality,
                  let state = location.administrativeArea else { return nil }
            
            return "\(city), \(state)"
        } catch {
            return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack(alignment: .bottom) {
                    Text(workout.type.rawValue.prefix(1).uppercased() + workout.type.rawValue.dropFirst().lowercased())
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(getWorkoutStartDateTime(from: workout.workout))
                        if let workoutLocationString {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.gray)
                                
                                Text(workoutLocationString)
                            }
                        }
                    }.redacted(reason: state == .loading ? .placeholder : [])
                }
                .padding(.top, 10)
                .padding(.horizontal)
                .foregroundStyle(.gray)
                
                HStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color.Foreground.default)
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
                            .foregroundStyle(Color.Foreground.default)
                        
                        Text("Miles")
                            .foregroundColor(.gray)
                            .padding(.leading)
                    }.padding(.leading)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                // MARK: - Workout Details
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    VStack(alignment: .leading) {
                        Text(workout.averagePace)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primary)
                        Text("Avg. Pace")
                    }.frame(width: 100)
                    
                    
                    
                    VStack(alignment: .leading) {
                        Text("\(workout.totalCaloriesBurned, specifier: "%.0f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        Text("Calories")
                    }
                    
                    
                    
                    VStack(alignment: .leading) {
                        Text(workout.totalTime)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.Brand.tertiary)
                        Text("Time")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("\(workout.averageHeartRate, specifier: "%.0f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.Brand.secondary)
                        Text("Avg. Heart Rate")
                    }
                    .frame(width: 100)
                    .redacted(reason: state == .loading ? .placeholder : [])
                    
                    
                    
                    VStack(alignment: .leading) {
                        Text(elevationGain)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Elevation Gain")
                    }
                    .frame(width: 100)
                    .redacted(reason: state == .loading ? .placeholder : [])
                    
                    VStack(alignment: .leading) {
                        Text(cadence)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.Brand.quaternary)
                        Text("Cadence")
                    }
                    .frame(width: 100)
                    .redacted(reason: state == .loading ? .placeholder : [])
                }.padding(.top, 10)
                
                // Workout Splits view
                if !workout.paceSegments.isEmpty {
                    let hasElevation = workout.paceSegments.contains { $0.elevationGain > 0 || $0.elevationLoss > 0 }
                    WorkoutSplitsView(splits: workout.paceSegments, hasElevationData: hasElevation)
                        .padding(.top)
                        .redacted(reason: state == .loading ? .placeholder : [])
                }
                
                // Workout map view
                if !workout.route2DPoints.isEmpty {
                    Group {
                        switch workout.type {
                        case .running, .walking, .cycling, .hiking:
                            WorkoutMapView(gradient: gradientColors, locations: workout.route2DPoints)
                                .redacted(reason: state == .loading ? .placeholder : [])
                        case .tennis, .basketball, .soccer, .football, .pickleball, .racquetball, .volleyball:
                            WorkoutHeatmapMapView(coordinates: ACTIVITY_POINTS, sportType: "soccer")
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.top)
                    .redacted(reason: state == .loading ? .placeholder : [])
                }
                
                // Workout Statistics View
                WorkoutStatistics(workout: workout, showHeartDetails: $showHeartDetails)
                    .redacted(reason: state == .loading ? .placeholder : [])
            }
            .navigationTitle(activityName)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showHeartDetails) {
                WorkoutHeartStatisticsView(workout: workout)
                    .environment(manager)
            }
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
            
            // Handle location data
            if !workout.locationSamples.isEmpty {
                if let point = workout.locationSamples.first {
                    workoutLocationString = await getWorkoutLocation(coordinate: point)
                }
                guard manager.zones.isEmpty else {
                    gradientColors = generateHeartRateZoneColors()
                    state = .success
                    return
                }
                manager.zones = await manager.generateHeartRateZones()
                gradientColors = generateHeartRateZoneColors()
            }
            state = .success
        }
    }
}

/* HealthKit disabled - Preview requires HKWorkout
#Preview {
    NavigationStack {
        WorkoutView(activityName: "Friday Evening Run", workout: Workout(type: .running, workout: HKWorkout(activityType: .running, start: Date(), end: Date().addingTimeInterval(30 * 60))))
            .environment(WorkoutManager())
    }
}
*/
