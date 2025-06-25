//
//  WorkoutManager+Splits.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/23/25.
//

import HealthKit
import Foundation
import CoreLocation

extension WorkoutManager {
    /// Generates running splits using distance samples with optional elevation data from locations
    /// - Parameters:
    ///   - distanceSamples: HealthKit distance samples from the workout
    ///   - locations: Array of location samples (used only for elevation data)
    ///   - workout: The workout to calculate splits for
    /// - Returns: Array of pace segments with distance, pace, and optional elevation data
    func generateRunningSplits(from distanceSamples: [HKQuantitySample], locations: [CLLocation], for workout: HKWorkout) -> [PaceSegment] {
        // Only generate splits for running workouts
        guard workout.workoutActivityType == .running else { return [] }
        
        // Use distance samples if available, otherwise fallback to basic splits
        guard !distanceSamples.isEmpty else {
            return generateBasicTimeSplits(for: workout)
        }
        
        // Generate splits from distance samples with optional elevation data
        return generateSplitsFromDistanceSamples(distanceSamples, locations: locations, workout: workout)
    }
    
    /// Gets location samples within a specific time range for elevation calculation
    private func getLocationsForTimeRange(locations: [CLLocation], startTime: Date, endTime: Date) -> [CLLocation] {
        return locations.filter { location in
            location.timestamp >= startTime && location.timestamp <= endTime
        }
    }
    
    /// Generates splits using HealthKit distance samples for precise pace calculation with optional elevation
    private func generateSplitsFromDistanceSamples(_ samples: [HKQuantitySample], locations: [CLLocation], workout: HKWorkout) -> [PaceSegment] {
        let splitDistance: Double = unit == UnitLength.miles ? 1609.344 : 1000.0 // 1 mile or 1 km in meters
        let detailInterval: Double = unit == UnitLength.miles ? 160.9344 : 100.0 // 0.1 mile or 0.1km
        
        var splits: [PaceSegment] = []
        var currentDistance: Double = 0
        var splitStartTime = workout.startDate
        var splitStartSampleIndex = 0
        
        let meterUnit = HKUnit.meter()
        
        for (index, sample) in samples.enumerated() {
            let sampleDistance = sample.quantity.doubleValue(for: meterUnit)
            currentDistance += sampleDistance
            
            // Check if we've completed a split
            if currentDistance >= splitDistance {
                let splitEndTime = sample.endDate
                let duration = splitEndTime.timeIntervalSince(splitStartTime)
                
                // Get detailed samples for this split (for 0.1km/0.1mi breakdown)
                let splitSamples = Array(samples[splitStartSampleIndex...index])
                
                // Calculate elevation if location data is available
                let elevationData: (gain: Double, loss: Double)
                if !locations.isEmpty {
                    let splitLocations = getLocationsForTimeRange(
                        locations: locations,
                        startTime: splitStartTime,
                        endTime: splitEndTime
                    )
                    elevationData = calculateElevationChange(for: splitLocations)
                } else {
                    elevationData = (gain: 0, loss: 0)
                }
                
                let split = PaceSegment(
                    segmentNumber: splits.count + 1,
                    distance: splitDistance,
                    duration: duration,
                    pace: duration / (splitDistance / (unit == UnitLength.miles ? 1609.344 : 1000.0)),
                    elevationGain: elevationData.gain,
                    elevationLoss: elevationData.loss,
                    startTime: splitStartTime,
                    endTime: splitEndTime,
                    detailSamples: generateDetailSamples(from: splitSamples, interval: detailInterval)
                )
                
                splits.append(split)
                
                // Reset for next split
                currentDistance = 0
                splitStartTime = splitEndTime
                splitStartSampleIndex = index + 1
            }
        }
        
        // Handle remaining partial split (minimum 0.05 mile/km or ~80 meters)
        if currentDistance >= splitDistance * 0.05 && splitStartSampleIndex < samples.count {
            let splitEndTime = samples.last!.endDate
            let duration = splitEndTime.timeIntervalSince(splitStartTime)
            let splitSamples = Array(samples[splitStartSampleIndex..<samples.count])
            
            // Calculate elevation for partial split if location data is available
            let elevationData: (gain: Double, loss: Double)
            if !locations.isEmpty {
                let splitLocations = getLocationsForTimeRange(
                    locations: locations,
                    startTime: splitStartTime,
                    endTime: splitEndTime
                )
                elevationData = calculateElevationChange(for: splitLocations)
            } else {
                elevationData = (gain: 0, loss: 0)
            }
            
            let split = PaceSegment(
                segmentNumber: splits.count + 1,
                distance: currentDistance,
                duration: duration,
                pace: duration / (currentDistance / (unit == UnitLength.miles ? 1609.344 : 1000.0)),
                elevationGain: elevationData.gain,
                elevationLoss: elevationData.loss,
                startTime: splitStartTime,
                endTime: splitEndTime,
                detailSamples: generateDetailSamples(from: splitSamples, interval: detailInterval)
            )
            
            splits.append(split)
        }
        
        return splits
    }
    
    /// Generates detailed samples for sub-split analysis (0.1km or 0.1 mile intervals)
    private func generateDetailSamples(from samples: [HKQuantitySample], interval: Double) -> [PaceDetailSample] {
        var detailSamples: [PaceDetailSample] = []
        var currentDistance: Double = 0
        var intervalStartTime = samples.first?.startDate ?? Date()
        var intervalStartIndex = 0
        
        let meterUnit = HKUnit.meter()
        
        for (index, sample) in samples.enumerated() {
            let sampleDistance = sample.quantity.doubleValue(for: meterUnit)
            currentDistance += sampleDistance
            
            if currentDistance >= interval {
                let intervalEndTime = sample.endDate
                let duration = intervalEndTime.timeIntervalSince(intervalStartTime)
                
                let detailSample = PaceDetailSample(
                    distance: interval,
                    duration: duration,
                    pace: duration / (interval / (unit == UnitLength.miles ? 1609.344 : 1000.0)),
                    startTime: intervalStartTime,
                    endTime: intervalEndTime
                )
                
                detailSamples.append(detailSample)
                
                // Reset for next interval
                currentDistance = 0
                intervalStartTime = intervalEndTime
                intervalStartIndex = index + 1
            }
        }
        
        return detailSamples
    }
    
    /// Fallback method for basic time-based splits when no distance samples available
    private func generateBasicTimeSplits(for workout: HKWorkout) -> [PaceSegment] {
        guard let totalDistance = workout.totalDistance?.doubleValue(for: unit == UnitLength.miles ? .mile() : .meter()),
              totalDistance > 0 else { return [] }
        
        let workoutDuration = workout.duration
        let splitDistance: Double = unit == UnitLength.miles ? 1.0 : 1000.0
        let splitDistanceInMeters: Double = unit == UnitLength.miles ? 1609.344 : 1000.0
        
        let numberOfFullSplits = Int(totalDistance / splitDistance)
        var splits: [PaceSegment] = []
        
        let averagePacePerMeter = workoutDuration / (totalDistance * (unit == UnitLength.miles ? 1609.344 : 1.0))
        
        for splitIndex in 0..<numberOfFullSplits {
            let splitDuration = averagePacePerMeter * splitDistanceInMeters
            let startTime = workout.startDate.addingTimeInterval(Double(splitIndex) * splitDuration)
            let endTime = startTime.addingTimeInterval(splitDuration)
            
            let split = PaceSegment(
                segmentNumber: splitIndex + 1,
                distance: splitDistanceInMeters,
                duration: splitDuration,
                pace: averagePacePerMeter * (unit == UnitLength.miles ? 1609.344 : 1000.0),
                elevationGain: 0,
                elevationLoss: 0,
                startTime: startTime,
                endTime: endTime
            )
            
            splits.append(split)
        }
        
        return splits
    }
    
    /// Calculates elevation gain and loss for a segment of locations
    /// - Parameter locations: Array of locations to analyze
    /// - Returns: Tuple containing elevation gain and loss in meters
    private func calculateElevationChange(for locations: [CLLocation]) -> (gain: Double, loss: Double) {
        guard locations.count > 1 else { return (0, 0) }
        
        var totalGain: Double = 0
        var totalLoss: Double = 0
        
        // Apply smoothing to reduce GPS noise in elevation data
        let smoothedElevations = smoothElevations(locations.map { $0.altitude })
        
        for i in 1..<smoothedElevations.count {
            let elevationChange = smoothedElevations[i] - smoothedElevations[i - 1]
            
            if elevationChange > 0 {
                totalGain += elevationChange
            } else {
                totalLoss += abs(elevationChange)
            }
        }
        
        return (gain: totalGain, loss: totalLoss)
    }
    
    /// Applies a simple moving average to smooth elevation data and reduce GPS noise
    /// - Parameter elevations: Raw elevation data
    /// - Returns: Smoothed elevation data
    private func smoothElevations(_ elevations: [Double]) -> [Double] {
        guard elevations.count > 2 else { return elevations }
        
        let windowSize = 3
        var smoothed: [Double] = []
        
        for i in 0..<elevations.count {
            let start = max(0, i - windowSize/2)
            let end = min(elevations.count - 1, i + windowSize/2)
            
            let window = Array(elevations[start...end])
            let average = window.reduce(0, +) / Double(window.count)
            smoothed.append(average)
        }
        
        return smoothed
    }
}
