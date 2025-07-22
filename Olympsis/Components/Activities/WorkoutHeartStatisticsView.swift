//
//  WorkoutHeartStatisticsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/17/25.
//

import SwiftUI
import Charts
import HealthKit

struct WorkoutHeartStatisticsView: View {
    let workout: Workout
    @Environment(WorkoutManager.self) private var workoutManager
    @State private var heartRateZones: [HeartRateZone] = []
    @State private var zoneTimeSpent: [ZoneTimeData] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Heart Rate Analysis")
                        .font(.custom("Archivo-SemiBold", size: 24, relativeTo: .title))
                    
                    if !workout.heartSamples.isEmpty {
                        Text("Average: \(Int(workout.averageHeartRate)) BPM")
                            .font(.custom("Archivo-Medium", size: 16, relativeTo: .body))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Heart Rate Graph
                if !workout.heartSamples.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Heart Rate Over Time")
                            .font(.custom("Archivo-Medium", size: 18, relativeTo: .headline))
                            .padding([.horizontal, .bottom])
                        
                        Chart {
                            ForEach(heartRateDataPoints(), id: \.timestamp) { dataPoint in
                                LineMark(
                                    x: .value("Time", dataPoint.timestamp),
                                    y: .value("Heart Rate", dataPoint.heartRate)
                                )
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(.red)
                            }
                            
                            // Add zone background areas
                            ForEach(Array(heartRateZones.enumerated()), id: \.offset) { index, zone in
                                RectangleMark(
                                    yStart: .value("Zone Min", zone.minHeartRate),
                                    yEnd: .value("Zone Max", zone.maxHeartRate)
                                )
                                .foregroundStyle(zoneColor(for: index + 1).opacity(0.3))
                            }
                        }
                        .chartYScale(domain: chartYDomain())
                        .frame(height: 175)
                        .padding(.horizontal)
                    }
                }
                
                // Heart Rate Zones Pie Chart
                if !heartRateZones.isEmpty && !zoneTimeSpent.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Time in Heart Rate Zones")
                            .font(.custom("Archivo-Medium", size: 18, relativeTo: .headline))
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            // Pie Chart
                            Chart(zoneTimeSpent) { zoneData in
                                SectorMark(
                                    angle: .value("Time", zoneData.timeSpent),
                                    innerRadius: .ratio(0.5),
                                    outerRadius: .ratio(0.8)
                                )
                                .foregroundStyle(zoneColor(for: zoneData.zoneNumber))
                            }
                            .frame(width: 120, height: 120)
                            
                            // Legend
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(zoneTimeSpent) { zoneData in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(zoneColor(for: zoneData.zoneNumber))
                                            .frame(width: 12, height: 12)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(zoneData.zoneName)
                                                .font(.custom("Archivo-Medium", size: 14, relativeTo: .caption))
                                            
                                            Text(formatDuration(zoneData.timeSpent))
                                                .font(.custom("Archivo-Regular", size: 12, relativeTo: .caption2))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        
                        // Zone Details
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Zone Details")
                                .padding(.bottom, 10)
                                .font(.custom("Archivo-Medium", size: 18, relativeTo: .headline))
                            
                            ForEach(Array(heartRateZones.enumerated()), id: \.offset) { index, zone in
                                HStack {
                                    Circle()
                                        .fill(zoneColor(for: index + 1))
                                        .frame(width: 8, height: 8)
                                    
                                    Text(zone.name.components(separatedBy: ":").first ?? "")
                                        .font(.custom("Archivo-Regular", size: 14, relativeTo: .caption))
                                    
                                    Spacer()
                                    
                                    Text("\(zone.minHeartRate)-\(zone.maxHeartRate) BPM")
                                        .font(.custom("Archivo-Regular", size: 14, relativeTo: .caption))
                                        .foregroundColor(.secondary)
                                    
                                    Text(zone.intensityRange)
                                        .font(.custom("Archivo-Regular", size: 14, relativeTo: .caption))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .task {
            await loadHeartRateZones()
            // Need to calculate zone time after zones are loaded
            if !heartRateZones.isEmpty {
                calculateZoneTimeSpent()
            }
        }
    }
    
    /// Data structure for heart rate time series
    private struct HeartRateDataPoint {
        let timestamp: Date
        let heartRate: Double
    }
    
    /// Data structure for zone time spent
    private struct ZoneTimeData: Identifiable {
        let id = UUID()
        let zoneNumber: Int
        let zoneName: String
        let timeSpent: TimeInterval
    }
    
    /// Convert heart rate samples to chart data points
    private func heartRateDataPoints() -> [HeartRateDataPoint] {
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        return workout.heartSamples.map { sample in
            HeartRateDataPoint(
                timestamp: sample.startDate,
                heartRate: sample.quantity.doubleValue(for: heartRateUnit)
            )
        }
    }
    
    /// Load heart rate zones from WorkoutManager
    private func loadHeartRateZones() async {
        guard workoutManager.zones.isEmpty else {
            heartRateZones = workoutManager.zones
            return
        }
        heartRateZones = await workoutManager.generateHeartRateZones()
        workoutManager.zones = heartRateZones
    }
    
    /// Calculate chart Y-axis domain for better zoom
    private func chartYDomain() -> ClosedRange<Double> {
        guard !workout.heartSamples.isEmpty else { return 60...200 }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let heartRates = workout.heartSamples.map { $0.quantity.doubleValue(for: heartRateUnit) }
        
        let minHR = heartRates.min() ?? 60
        let maxHR = heartRates.max() ?? 200
        
        return (minHR - 5)...(maxHR + 10)
    }
    
    /// Local helper to determine heart rate zone
    private func getZoneFromHeartRate(_ heartRate: Double) -> Int {
        guard !heartRateZones.isEmpty else { return 2 }
        
        let heartRateInt = Int(heartRate.rounded())
        
        for (index, zone) in heartRateZones.enumerated() {
            if heartRateInt >= zone.minHeartRate && heartRateInt <= zone.maxHeartRate {
                return index + 1 // Return 1-based zone number
            }
        }
        
        // If heart rate is below all zones, return zone 1
        // If heart rate is above all zones, return highest zone
        if heartRateInt < heartRateZones.first!.minHeartRate {
            return 1
        } else {
            return heartRateZones.count
        }
    }
    
    /// Calculate time spent in each heart rate zone
    private func calculateZoneTimeSpent() {
        guard !heartRateZones.isEmpty && !workout.heartSamples.isEmpty else { return }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        var zoneTimeMap: [Int: TimeInterval] = [:]
        
        // Initialize zone time tracking
        for i in 1...heartRateZones.count {
            zoneTimeMap[i] = 0
        }
        
        // Sort samples by time to ensure proper duration calculation
        let sortedSamples = workout.heartSamples.sorted { $0.startDate < $1.startDate }
        
        // Calculate time spent in each zone
        for i in 0..<sortedSamples.count {
            let sample = sortedSamples[i]
            let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
            let zone = getZoneFromHeartRate(heartRate)
            
            // Calculate sample duration (time between this sample and next)
            let sampleDuration: TimeInterval
            if i < sortedSamples.count - 1 {
                sampleDuration = sortedSamples[i + 1].startDate.timeIntervalSince(sample.startDate)
            } else {
                // For last sample, use the duration from the previous sample or default
                if i > 0 {
                    sampleDuration = sample.startDate.timeIntervalSince(sortedSamples[i - 1].startDate)
                } else {
                    sampleDuration = 1.0 // Fallback for single sample
                }
            }
            
            // Only count reasonable durations (avoid huge gaps)
            let clampedDuration = min(sampleDuration, 30.0) // Max 30 seconds between samples
            zoneTimeMap[zone, default: 0] += clampedDuration
        }
        
        // Convert to ZoneTimeData array
        zoneTimeSpent = heartRateZones.enumerated().compactMap { index, zone in
            let zoneNumber = index + 1
            let timeSpent = zoneTimeMap[zoneNumber] ?? 0
            
            // Only include zones with time spent > 0
            guard timeSpent > 0 else { return nil }
            
            return ZoneTimeData(
                zoneNumber: zoneNumber,
                zoneName: zone.name,
                timeSpent: timeSpent
            )
        }
        
        // Debug logging
        print("Zone time calculation results:")
        for (zoneNumber, time) in zoneTimeMap.sorted(by: { $0.key < $1.key }) {
            print("Zone \(zoneNumber): \(formatDuration(time))")
        }
        
        print("Heart Rate Zones:")
        for (index, zone) in heartRateZones.enumerated() {
            print("Zone \(index + 1): \(zone.name) - \(zone.minHeartRate)-\(zone.maxHeartRate) BPM")
        }
        
        // Sample some heart rates to verify zone calculation
        if !sortedSamples.isEmpty {
            let sampleCount = min(5, sortedSamples.count)
            print("Sample heart rates and zones:")
            for i in 0..<sampleCount {
                let sample = sortedSamples[i]
                let hr = sample.quantity.doubleValue(for: heartRateUnit)
                let zone = getZoneFromHeartRate(hr)
                print("HR: \(Int(hr)) -> Zone \(zone)")
            }
        }
    }
    
    /// Get color for heart rate zone
    private func zoneColor(for zoneNumber: Int) -> Color {
        switch zoneNumber {
        case 1: return .blue      // Zone 1: Light
        case 2: return .green     // Zone 2: Moderate
        case 3: return .yellow    // Zone 3: Hard
        case 4: return .orange    // Zone 4: Maximum
        case 5: return .red       // Zone 5: All Out
        default: return .gray
        }
    }
    
    /// Format duration for display
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    // Create a sample workout for preview
    let sampleWorkout = Workout(
        type: .running,
        workout: HKWorkout(
            activityType: .running,
            start: Date().addingTimeInterval(-3600),
            end: Date()
        )
    )
    
    WorkoutHeartStatisticsView(workout: sampleWorkout)
        .environment(WorkoutManager())
}
