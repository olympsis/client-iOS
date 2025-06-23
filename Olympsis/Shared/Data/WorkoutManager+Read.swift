//
//  WorkoutManager+Read.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/3/24.
//

import os
import HealthKit
import Foundation
import CoreLocation

extension WorkoutManager {
    
    @MainActor
    func fetchWorkoutsHistory(in datePredicate: String?) async {
        guard checkAuthorizationStatus() else {
            return
        }
        await MainActor.run {
            self.viewState = .loading
        }
//        let workouts = await fetchAllWorkoutHistory(in: datePredicate)
        let workouts: [Workout] = []
        await MainActor.run {
            self.workouts = workouts
        }
        await MainActor.run {
            self.viewState = .pending
        }
    }
    
    func loadWorkouts(dateRange: DateInterval? = nil) async -> [Workout] {
        let datePredicate = buildDatePredicate(
            dateRange: dateRange,
            cursor: self.fetchingCursor
        )
        
        // Fetch workouts for all sports in a single query
        let workoutPredicates = SUPPORTED_SPORTS.allCases.map {
            HKQuery.predicateForWorkouts(with: $0.getWorkoutActivityType())
        }
        let workoutPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: workoutPredicates  // OR, not AND!
        )
        
        // Combine workout predicate with date predicate using AND
        var predicates: [NSPredicate] = [workoutPredicate]
        if let datePredicate {
            predicates.append(datePredicate)
        }
        
        let combinedPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: predicates
        )
        
        do {
            let workouts = try await fetchWorkouts(predicate: combinedPredicate)
            // Keep track of pointer in loaded workouts
            self.fetchingCursor = workouts.last?.startDate
            
            // If we did get a full batch then we create a background task to fetch the rest
            if workouts.count == 20 {
                self.backgroundTask = Task(priority: .background) {
                    let results = await loadWorkouts()
                    await MainActor.run {
                        self.workouts.append(contentsOf: results)
                    }
                }
            }
            
            let processedWorkouts = await batchProcessWorkouts(workouts)
            self.workouts.append(contentsOf: processedWorkouts)
            return processedWorkouts
        } catch {
            log.error("Failed to fetch workouts: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Queries HealthKit for the workout generic data
    /// - Parameters:
    ///     - predicate: filter to help us refine our query for the workouts
    ///     - batch: upper-bound limit for fetching workouts
    ///
    /// - Returns: an array containing the HealthKit workout data
    func fetchWorkouts(predicate: NSPredicate, batch: Int = 20) async throws -> [HKWorkout] {
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: batch,
                sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let workouts = results as? [HKWorkout] {
                    continuation.resume(returning: workouts)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: WorkoutError.failedQuery)
                }
            }
            healthStore.execute(query)
        }
    }
    
    /// Queries HealthKit for the location data for a workout
    /// - Parameters:
    ///     - workout: the workout we need to pull data form
    ///
    /// - Returns: an array containing the location data for the workout
    func fetchWorkoutRoute(from workout: HKWorkout) async throws -> [CLLocation] {
        // First get the workout routes
        let workoutRoutes = try await fetchWorkoutRoutes(for: workout)
        
        guard !workoutRoutes.isEmpty else { return [] }
        
        // Then fetch location data for each route using TaskGroup
        return try await withThrowingTaskGroup(of: (Int, [CLLocation]).self) { group in
            for (index, route) in workoutRoutes.enumerated() {
                group.addTask {
                    let locations = try await self.fetchLocations(for: route)
                    return (index, locations)
                }
            }
            
            var routeSegments: [(index: Int, locations: [CLLocation])] = []
            for try await (index, locations) in group {
                routeSegments.append((index: index, locations: locations))
            }
            
            // Sort by route index, then by timestamp
            return routeSegments
                .sorted { $0.index < $1.index }
                .flatMap { $0.locations }
                .sorted { $0.timestamp < $1.timestamp }
        }
    }
    
    private func fetchWorkoutRoutes(for workout: HKWorkout) async throws -> [HKWorkoutRoute] {
        return try await withCheckedThrowingContinuation { continuation in
            let workoutPredicate = HKQuery.predicateForObjects(from: workout)
            
            let query = HKSampleQuery(
                sampleType: HKSeriesType.workoutRoute(),
                predicate: workoutPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { (query, results, error) in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let workoutRouteSamples = results as? [HKWorkoutRoute] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: workoutRouteSamples)
            }
            
            self.healthStore.execute(query)
        }
    }

    private func fetchLocations(for route: HKWorkoutRoute) async throws -> [CLLocation] {
        return try await withCheckedThrowingContinuation { continuation in
            var locations: [CLLocation] = []
            var hasError = false
            
            let locationQuery = HKWorkoutRouteQuery(route: route) { (query, routeData, done, error) in
                if let error = error {
                    if !hasError {
                        hasError = true
                        continuation.resume(throwing: error)
                    }
                    return
                }
                
                if let routeData = routeData {
                    locations.append(contentsOf: routeData)
                }
                
                if done {
                    if !hasError {
                        // Sort locations by timestamp to ensure proper ordering
                        let sortedLocations = locations.sorted { $0.timestamp < $1.timestamp }
                        continuation.resume(returning: sortedLocations)
                    }
                }
            }
            
            self.healthStore.execute(locationQuery)
        }
    }
    
    func fetchWorkoutAdditionalData(from workout: HKWorkout) async -> WorkoutDetails? {
        do {
            async let cadence = fetchAverageStatistic(
                from: workout,
                type: getCadenceType(for: workout.workoutActivityType),
                unit: HKUnit.count().unitDivided(by: .minute())
            )
            
            async let locationSamples = fetchWorkoutRoute(from: workout)
            async let heartRateSamples = fetchSamplesForUnit(from: workout, for: .heartRate)
            async let distanceSamples = fetchSamplesForUnit(
                from: workout,
                for: getDistanceType(for: workout.workoutActivityType)
            )
            
            let (cd, ls, hs, ds) = try await (cadence, locationSamples, heartRateSamples, distanceSamples)
            
            // Generate running splits with or without elevation data
            let splits = await generateRunningSplits(from: ls, for: workout)
            
            return WorkoutDetails(
                route: ls,
                cadence: cd ?? 0,
                paceSegments: splits,
                heartRateSamples: hs,
                splits: splits
            )
        } catch {
            log.error("Failed to get workout additional data. Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Process a batch of workouts to get heart rate and calorie data
    /// - Parameters:
    ///     - workouts: the batch of workouts to process
    ///
    /// - Returns: an array of the processed workouts
    private func batchProcessWorkouts(_ workouts: [HKWorkout]) async -> [Workout] {
        // Group workouts by type for efficient processing
        let groupedWorkouts = Dictionary(grouping: workouts) { $0.workoutActivityType }
        
        return await withTaskGroup(of: [Workout].self) { group in
            for (activityType, workoutsOfType) in groupedWorkouts {
                group.addTask {
                    await self.processWorkoutBatch(workoutsOfType, activityType: activityType)
                }
            }
            
            var allProcessed: [Workout] = []
            for await batch in group {
                allProcessed.append(contentsOf: batch)
            }
            
            // Sort by date to maintain order
            return allProcessed.sorted { $0.workout.startDate > $1.workout.startDate }
        }
    }
    
    /// Processes a workout batch by confirming the activity type and fetching the statistics for the workout batch
    /// - Parameters:
    ///     - workouts: the batch of workouts to process
    ///
    /// - Returns: an array of the processed workouts with the calories and heart rate stats
    private func processWorkoutBatch(_ workouts: [HKWorkout], activityType: HKWorkoutActivityType) async -> [Workout] {
        guard let sport = sportFromActivityType(activity: activityType) else {
            return []
        }
        
        // Fetch statistics for all workouts in batch
        let statistics = await fetchBatchStatistics(for: workouts)
        
        return workouts.compactMap { workout -> Workout? in
            guard let stats = statistics[workout.uuid] else { return nil }
            
            return Workout(
                type: sport,
                workout: workout,
                totalDistance: stats.totalDistance,
                totalCalories: stats.calories
            )
        }
    }
    
    /// Handles fetching the statistics for a batch of workouts
    /// - Parameters:
    ///     - workouts: the batch of workouts to process
    ///
    /// - Returns: a dictionary with the key of the workout and the workout statistics (calories burned & heart rate)
    private func fetchBatchStatistics(for workouts: [HKWorkout]) async -> [UUID: WorkoutStatistics] {
        var results: [UUID: WorkoutStatistics] = [:]
        
        await withTaskGroup(of: (UUID, WorkoutStatistics).self) { group in
            for workout in workouts {
                group.addTask {
                    let stats = await self.fetchWorkoutStatistics(workout)
                    return (workout.uuid, stats)
                }
            }
            
            for await (uuid, stats) in group {
                results[uuid] = stats
            }
        }
        
        return results
    }
    
    /// Queries HealthKit for the workout statistics
    /// - Parameters:
    ///     - workouts: the workout to fetch statistics for
    ///
    /// - Returns: the workout statistics object containing the average of those statistics
    private func fetchWorkoutStatistics(_ workout: HKWorkout) async -> WorkoutStatistics {
        async let calories = fetchAverageStatistic(
            from: workout,
            type: .activeEnergyBurned,
            unit: .kilocalorie()
        )
        
        async let totalDistance = fetchAverageStatistic(
            from: workout,
            type: getDistanceType(for: workout.workoutActivityType),
            unit: self.unit == UnitLength.miles ? HKUnit.mile() : HKUnit.meter()
        )
        
        return await WorkoutStatistics(
            calories: calories ?? 0,
            totalDistance: totalDistance ?? 0
        )
    }
    
    /// Queries HealthKit samples data from workout for a specific unit type
    /// - Parameters:
    ///     - workout: the workout we need to pull data for
    ///     - quantityType: the unity type we want to fetch data for
    ///
    /// - Returns: an array of HealthKit quantity samples
    private func fetchSamplesForUnit(from workout: HKWorkout, for quantityType: HKQuantityTypeIdentifier) async throws -> [HKQuantitySample] {
        guard let type = HKQuantityType.quantityType(forIdentifier: quantityType) else { return [] }
        
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        var predicate = HKQuery.predicateForObjects(from: workout)
        
        if quantityType == .heartRate {
            predicate = HKQuery.predicateForSamples(
                withStart: workout.startDate,
                end: workout.endDate,
                options: .strictStartDate
            )
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type,
                                      predicate: predicate,
                                      limit: 0,
                                      sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let samples = results as? [HKQuantitySample] {
                    continuation.resume(returning: samples)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: WorkoutError.failedQuery)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    /// Queries HealthKit average statistic for a workout unit
    /// - Parameters:
    ///     - workout: the workout we are fetching the unit average from
    ///     - type: the statistic unit type
    ///     - unit: the method to calculate the average of our unit
    ///
    /// - Returns: a double expressing the average of the statistic
    private func fetchAverageStatistic(from workout: HKWorkout, type: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: type) else { return nil }
        
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        // Determine the correct statistics option based on quantity type
        let statisticsOption: HKStatisticsOptions = {
            switch type {
            // Discrete types - use average
            case .heartRate,
                 .heartRateVariabilitySDNN,
                 .respiratoryRate,
                 .oxygenSaturation,
                 .bodyTemperature,
                 .cyclingCadence,
                 .runningStrideLength,
                 .bloodPressureSystolic,
                 .bloodPressureDiastolic:
                return .discreteAverage
                
            // Cumulative types - use sum
            case .activeEnergyBurned,
                 .basalEnergyBurned,
                 .distanceWalkingRunning,
                 .distanceCycling,
                 .distanceSwimming,
                 .stepCount,
                 .flightsClimbed,
                 .swimmingStrokeCount:
                return .cumulativeSum
                
            default:
                // For unknown types, check if it's cumulative
                return quantityType.aggregationStyle == .cumulative ? .cumulativeSum : .discreteAverage
            }
        }()
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: statisticsOption
            ) { _, result, error in
                if let statistics = result {
                    // Handle the result based on the option used
                    if statisticsOption == .cumulativeSum {
                        if let sum = statistics.sumQuantity() {
                            continuation.resume(returning: sum.doubleValue(for: unit))
                        } else {
                            continuation.resume(returning: nil)
                        }
                    } else {
                        if let average = statistics.averageQuantity() {
                            continuation.resume(returning: average.doubleValue(for: unit))
                        } else {
                            continuation.resume(returning: nil)
                        }
                    }
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            self.healthStore.execute(query)
        }
    }
    
    /// Generates running splits with optional elevation data from location samples or workout duration
    /// - Parameters:
    ///   - locations: Array of location samples from the workout (can be empty)
    ///   - workout: The workout to calculate splits for
    /// - Returns: Array of pace segments with distance, pace, and optional elevation data
    private func generateRunningSplits(from locations: [CLLocation], for workout: HKWorkout) async -> [PaceSegment] {
        // Only generate splits for running workouts
        guard workout.workoutActivityType == .running else { return [] }
        
        // If we have location data, use GPS-based splits
        if !locations.isEmpty {
            return generateGPSSplits(from: locations, for: workout)
        }
        
        // Otherwise, generate time-based splits using workout distance and duration
        return await generateTimeBSplits(for: workout)
    }
    
    /// Generates GPS-based splits with elevation data
    private func generateGPSSplits(from locations: [CLLocation], for workout: HKWorkout) -> [PaceSegment] {
        let splitDistance: Double = unit == UnitLength.miles ? 1609.344 : 1000 // 1 mile or 1 km in meters
        var splits: [PaceSegment] = []
        var currentDistance: Double = 0
        var splitStartIndex = 0
        var splitStartTime = workout.startDate
        
        for (index, location) in locations.enumerated() {
            guard index > 0 else { continue }
            
            let previousLocation = locations[index - 1]
            let segmentDistance = location.distance(from: previousLocation)
            currentDistance += segmentDistance
            
            // Check if we've completed a split
            if currentDistance >= splitDistance {
                let splitEndTime = location.timestamp
                let duration = splitEndTime.timeIntervalSince(splitStartTime)
                
                // Calculate elevation gain/loss for this split
                let splitLocations = Array(locations[splitStartIndex...index])
                let elevationData = calculateElevationChange(for: splitLocations)
                
                // Calculate pace (time per unit distance)
                let paceInSeconds = duration / (splitDistance / (unit == UnitLength.miles ? 1609.344 : 1000))
                
                let split = PaceSegment(
                    segmentNumber: splits.count + 1,
                    distance: splitDistance,
                    duration: duration,
                    pace: paceInSeconds,
                    elevationGain: elevationData.gain,
                    elevationLoss: elevationData.loss,
                    startTime: splitStartTime,
                    endTime: splitEndTime
                )
                
                splits.append(split)
                
                // Reset for next split
                currentDistance = 0
                splitStartIndex = index
                splitStartTime = splitEndTime
            }
        }
        
        // Handle remaining partial split if significant distance covered
        if currentDistance > splitDistance * 0.1 && splitStartIndex < locations.count - 1 {
            let splitEndTime = locations.last!.timestamp
            let duration = splitEndTime.timeIntervalSince(splitStartTime)
            
            let splitLocations = Array(locations[splitStartIndex..<locations.count])
            let elevationData = calculateElevationChange(for: splitLocations)
            
            let paceInSeconds = duration / (currentDistance / (unit == UnitLength.miles ? 1609.344 : 1000))
            
            let split = PaceSegment(
                segmentNumber: splits.count + 1,
                distance: currentDistance,
                duration: duration,
                pace: paceInSeconds,
                elevationGain: elevationData.gain,
                elevationLoss: elevationData.loss,
                startTime: splitStartTime,
                endTime: splitEndTime
            )
            
            splits.append(split)
        }
        
        return splits
    }
    
    /// Generates HealthKit distance sample-based splits when GPS data is not available
    private func generateTimeBSplits(for workout: HKWorkout) async -> [PaceSegment] {
        // Fetch distance samples from HealthKit
        let distanceSamples = await fetchDistanceSamples(from: workout)
        
        guard !distanceSamples.isEmpty else {
            // Fallback to basic time-based splits if no distance samples
            return generateBasicTimeSplits(for: workout)
        }
        
        return generateSplitsFromDistanceSamples(distanceSamples, workout: workout)
    }
    
    /// Fetches aggregated distance samples from HealthKit for detailed pace analysis
    private func fetchDistanceSamples(from workout: HKWorkout) async -> [HKQuantitySample] {
        do {
            return try await fetchSamplesForUnit(
                from: workout,
                for: getDistanceType(for: workout.workoutActivityType)
            )
        } catch {
            log.error("Failed to fetch distance samples: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Generates splits using HealthKit distance samples for precise pace calculation
    private func generateSplitsFromDistanceSamples(_ samples: [HKQuantitySample], workout: HKWorkout) -> [PaceSegment] {
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
                
                // Get detailed samples for this split (for 100m/0.1mi breakdown)
                let splitSamples = Array(samples[splitStartSampleIndex...index])
                
                let split = PaceSegment(
                    segmentNumber: splits.count + 1,
                    distance: splitDistance,
                    duration: duration,
                    pace: duration / (splitDistance / (unit == UnitLength.miles ? 1609.344 : 1000.0)),
                    elevationGain: 0, // No elevation data available
                    elevationLoss: 0, // No elevation data available
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
        
        // Handle remaining partial split
        if currentDistance > splitDistance * 0.1 && splitStartSampleIndex < samples.count {
            let splitEndTime = samples.last!.endDate
            let duration = splitEndTime.timeIntervalSince(splitStartTime)
            let splitSamples = Array(samples[splitStartSampleIndex..<samples.count])
            
            let split = PaceSegment(
                segmentNumber: splits.count + 1,
                distance: currentDistance,
                duration: duration,
                pace: duration / (currentDistance / (unit == UnitLength.miles ? 1609.344 : 1000.0)),
                elevationGain: 0,
                elevationLoss: 0,
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
