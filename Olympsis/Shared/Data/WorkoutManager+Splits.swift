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
        
        
        // If we have location data, use GPS-based distance calculation instead of HealthKit distance samples
        if !locations.isEmpty && locations.count > 10 {
            return generateGPSBasedSplits(from: locations, for: workout)
        }
        guard !distanceSamples.isEmpty else {
            return generateBasicTimeSplits(for: workout)
        }
        
        // Generate splits from distance samples with optional elevation data
        return generateSplitsFromDistanceSamples(distanceSamples, locations: locations, workout: workout)
    }
    
    /// Generates splits using GPS location data for more accurate distance calculation
    private func generateGPSBasedSplits(from locations: [CLLocation], for workout: HKWorkout) -> [PaceSegment] {
        let splitDistance: Double = unit == UnitLength.miles ? 1609.344 : 1000.0 // 1 mile or 1 km in meters
        
        var splits: [PaceSegment] = []
        var currentDistance: Double = 0
        var splitStartTime = workout.startDate
        var splitStartIndex = 0
        
        // Sort locations by timestamp to ensure proper order
        let sortedLocations = locations.sorted { $0.timestamp < $1.timestamp }
        
        for (index, location) in sortedLocations.enumerated() {
            guard index > 0 else { continue } // Skip first location
            
            let previousLocation = sortedLocations[index - 1]
            let segmentDistance = previousLocation.distance(from: location)
            currentDistance += segmentDistance
            
            // Check if we've completed a split
            if currentDistance >= splitDistance {
                // Find the exact time when split distance was reached by interpolation
                let overshoot = currentDistance - splitDistance
                let segmentDuration = location.timestamp.timeIntervalSince(previousLocation.timestamp)
                let overshootTime = (overshoot / segmentDistance) * segmentDuration
                let splitEndTime = location.timestamp.addingTimeInterval(-overshootTime)
                
                let duration = splitEndTime.timeIntervalSince(splitStartTime)
                let conversionFactor = (unit == UnitLength.miles ? 1609.344 : 1000.0)
                let calculatedPace = duration / (splitDistance / conversionFactor)
                
                // Calculate elevation for this split
                let splitLocations = Array(sortedLocations[splitStartIndex...index])
                let elevationData = calculateElevationChange(for: splitLocations)
                
                let split = PaceSegment(
                    segmentNumber: splits.count + 1,
                    distance: splitDistance,
                    duration: duration,
                    pace: calculatedPace,
                    elevationGain: elevationData.gain,
                    elevationLoss: elevationData.loss,
                    startTime: splitStartTime,
                    endTime: splitEndTime
                )
                
                splits.append(split)
                
                
                // Reset for next split
                currentDistance = overshoot
                splitStartTime = splitEndTime
                splitStartIndex = index
            }
        }
        
        return splits
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
                // Calculate precise time when split distance was reached
                let overshoot = currentDistance - splitDistance
                let sampleDuration = sample.endDate.timeIntervalSince(sample.startDate)
                let overshootTime = (overshoot / sampleDistance) * sampleDuration
                let splitEndTime = sample.endDate.addingTimeInterval(-overshootTime)
                
                // Calculate active duration excluding pauses using workout events
                let duration = calculateActiveWorkoutTimeFromEvents(from: splitStartTime, to: splitEndTime, workout: workout)
                
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
                
                let conversionFactor = (unit == UnitLength.miles ? 1609.344 : 1000.0)
                let calculatedPace = duration / (splitDistance / conversionFactor)
                
                let split = PaceSegment(
                    segmentNumber: splits.count + 1,
                    distance: splitDistance,
                    duration: duration,
                    pace: calculatedPace,
                    elevationGain: elevationData.gain,
                    elevationLoss: elevationData.loss,
                    startTime: splitStartTime,
                    endTime: splitEndTime,
                    detailSamples: generateDetailSamples(from: splitSamples, interval: detailInterval)
                )
                
                splits.append(split)
                
                // Reset for next split, carrying forward overshoot distance and time
                currentDistance = overshoot
                splitStartTime = splitEndTime
                splitStartSampleIndex = index
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
    
    /// Calculates active workout time by detecting and excluding pauses
    /// - Parameters:
    ///   - startTime: Start time of the period
    ///   - endTime: End time of the period
    ///   - samples: HealthKit samples for this period
    /// - Returns: Active duration excluding paused periods
    private func calculateActiveWorkoutTime(from startTime: Date, to endTime: Date, samples: [HKQuantitySample]) -> TimeInterval {
        guard samples.count > 1 else { return endTime.timeIntervalSince(startTime) }
        
        var activeDuration: TimeInterval = 0
        let pauseThreshold: TimeInterval = 20 // If gap between samples > 20 seconds, consider it a pause
        
        for i in 1..<samples.count {
            let previousSample = samples[i-1]
            let currentSample = samples[i]
            
            let gapDuration = currentSample.startDate.timeIntervalSince(previousSample.endDate)
            
            if gapDuration > pauseThreshold {
                // This is likely a pause - only count the sample duration, not the gap
                activeDuration += previousSample.endDate.timeIntervalSince(previousSample.startDate)
            } else {
                // Normal continuous activity - count full duration including gap
                activeDuration += currentSample.startDate.timeIntervalSince(previousSample.startDate)
            }
        }
        
        // Add the last sample duration
        let lastSample = samples.last!
        activeDuration += lastSample.endDate.timeIntervalSince(lastSample.startDate)
        
        return activeDuration
    }
    
    /// Calculates active workout time using HealthKit workout events (pause/resume)
    /// - Parameters:
    ///   - startTime: Start time of the period
    ///   - endTime: End time of the period
    ///   - workout: HKWorkout with events
    /// - Returns: Active duration excluding paused periods based on workout events
    private func calculateActiveWorkoutTimeFromEvents(from startTime: Date, to endTime: Date, workout: HKWorkout) -> TimeInterval {
        guard let events = workout.workoutEvents, !events.isEmpty else {
            // No events, return raw duration
            return endTime.timeIntervalSince(startTime)
        }
        
        var activeDuration: TimeInterval = 0
        var currentTime = startTime
        var isPaused = false
        
        // Filter events to only those within our time range
        let relevantEvents = events.filter { event in
            event.dateInterval.start >= startTime && event.dateInterval.start <= endTime
        }
        
        for event in relevantEvents.sorted(by: { $0.dateInterval.start < $1.dateInterval.start }) {
            let eventTime = event.dateInterval.start
            
            if !isPaused {
                // Add time from current to pause
                activeDuration += eventTime.timeIntervalSince(currentTime)
            }
            
            if event.type == .pause {
                isPaused = true
            } else if event.type == .resume {
                isPaused = false
            }
            
            currentTime = eventTime
        }
        
        // Add remaining time if not paused
        if !isPaused && currentTime < endTime {
            let remainingTime = endTime.timeIntervalSince(currentTime)
            activeDuration += remainingTime
        }
        return activeDuration
    }
}
