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
    
    /// Creates a predicate for fetching workouts from all supported sports
    private func createSportsWorkoutPredicate() -> NSCompoundPredicate {
        let workoutPredicates = SUPPORTED_SPORTS.allCases.map {
            HKQuery.predicateForWorkouts(with: $0.getWorkoutActivityType())
        }
        return NSCompoundPredicate(
            orPredicateWithSubpredicates: workoutPredicates
        )
    }
    
    func fetchWorkoutsHistory(in datePredicate: String?) async {
        guard checkAuthorizationStatus() else {
            return
        }
        await MainActor.run {
            self.viewState = .loading
        }
        
        let workoutPredicate = createSportsWorkoutPredicate()
        
        do {
            let workouts: [Workout] = try await batchProcessWorkouts(
                fetchWorkouts(predicate: workoutPredicate, batch: 10)
            )
            await MainActor.run {
                self.workouts = workouts
                self.viewState = .pending
            }
        } catch {
            log.error("Failed to fetch workouts: \(error)")
        }
    }
    
    func loadWorkouts(dateRange: DateInterval? = nil) async -> [Workout] {
        let datePredicate = buildDatePredicate(
            dateRange: dateRange,
            cursor: self.fetchingCursor
        )
        
        let workoutPredicate = createSportsWorkoutPredicate()
        
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
                    let results = await loadWorkouts(dateRange: dateRange)
                    await MainActor.run {
                        self.appendUniqueWorkouts(results)
                    }
                }
            }
            
            let processedWorkouts = await batchProcessWorkouts(workouts)
            self.appendUniqueWorkouts(processedWorkouts)
            return processedWorkouts
        } catch {
            log.error("Failed to fetch workouts: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Appends workouts to the main workouts array, avoiding duplicates
    /// - Parameter newWorkouts: Array of workouts to append
    private func appendUniqueWorkouts(_ newWorkouts: [Workout]) {
        let existingWorkoutIds = Set(workouts.map { $0.workout.uuid })
        let uniqueWorkouts = newWorkouts.filter { !existingWorkoutIds.contains($0.workout.uuid) }
        workouts.append(contentsOf: uniqueWorkouts)
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
    
    /// Fetches running cadence by calculating steps per minute from total step count
    /// - Parameter workout: The HKWorkout to fetch cadence for
    /// - Returns: Running cadence in steps per minute, or nil if unavailable
    private func fetchRunningCadence(from workout: HKWorkout) async -> Double? {
        guard workout.workoutActivityType == .running || workout.workoutActivityType == .walking else {
            // For non-running activities, fall back to the original method
            return await fetchAverageStatistic(
                from: workout,
                type: getCadenceType(for: workout.workoutActivityType),
                unit: HKUnit.count().unitDivided(by: .minute())
            )
        }
        
        // For running, try step count first, then fall back to distance estimation
        if let cadence = await fetchStepCountCadence(for: workout) {
            // Only use step count if it's reasonable (160-200 steps/min for running)
            if cadence >= 140 && cadence <= 220 {
                return cadence
            } else {
                print("🏃‍♂️ Step count cadence (\(cadence)) seems unrealistic, using distance estimation instead")
            }
        }
        
        // Fallback: Try to get cadence from workout statistics if available
        if let cadenceFromStats = workout.allStatistics[HKQuantityType.quantityType(forIdentifier: .runningSpeed)!] {
            print("🏃‍♂️ Found running speed in workout statistics: \(cadenceFromStats)")
        }
        
        // Fallback: Estimate cadence using distance and typical running stride length
        if let totalDistance = workout.totalDistance?.doubleValue(for: HKUnit.meter()) {
            let activeWorkoutDuration = await calculateActiveWorkoutDurationFromEvents(workout: workout)
            let activeMinutes = activeWorkoutDuration / 60.0
            
            // TODO: Update stride length calculation based on user's height
            // Current value is calibrated to match device measurements (e.g., Nike Run Club)
            // Formula for height-based stride: stride = height * 0.415 (for running)
            let estimatedStrideLength = 1.23 // meters - UPDATE THIS TO USE USER HEIGHT
            
            let estimatedSteps = totalDistance / estimatedStrideLength
            let estimatedCadence = estimatedSteps / activeMinutes
            
            // Round to 0 decimals
            return round(estimatedCadence)
        }
        
        return nil
    }
    
    /// Calculates the active workout duration by excluding paused periods
    /// - Parameter workout: The HKWorkout to analyze
    /// - Returns: Active duration in seconds
    private func calculateActiveWorkoutDurationFromEvents(workout: HKWorkout) async -> TimeInterval {
        guard let events = workout.workoutEvents, !events.isEmpty else {
            // No pause/resume events, return total workout duration
            return workout.duration
        }
        
        var activeDuration: TimeInterval = 0
        var currentTime = workout.startDate
        var isPaused = false
        
        // Sort events by start time
        let sortedEvents = events.sorted { $0.dateInterval.start < $1.dateInterval.start }
        
        for event in sortedEvents {
            let eventTime = event.dateInterval.start
            
            if !isPaused {
                // Add active time from current position to pause
                activeDuration += eventTime.timeIntervalSince(currentTime)
            }
            
            if event.type == .pause {
                isPaused = true
            } else if event.type == .resume {
                isPaused = false
            }
            
            currentTime = eventTime
        }
        
        // Add remaining time if not paused at the end
        if !isPaused {
            activeDuration += workout.endDate.timeIntervalSince(currentTime)
        }
        
        return activeDuration
    }
    
    /// Fetches step count samples during active workout periods and calculates cadence
    /// - Parameter workout: The HKWorkout to fetch cadence for
    /// - Returns: Running cadence in steps per minute, or nil if unavailable
    private func fetchStepCountCadence(for workout: HKWorkout) async -> Double? {
        // Query step count samples for entire workout period (with some buffer)
        let bufferMinutes: TimeInterval = 5 * 60 // 5 minute buffer before/after
        let queryStart = workout.startDate.addingTimeInterval(-bufferMinutes)
        let queryEnd = workout.endDate.addingTimeInterval(bufferMinutes)
        
        do {
            let allStepSamples = try await fetchStepCountSamples(
                startDate: queryStart,
                endDate: queryEnd
            )
            
            // Filter and sum steps that overlap with active workout periods
            let activePeriods = getActiveWorkoutPeriods(for: workout)
            let totalActiveDuration = activePeriods.reduce(0) { $0 + $1.duration }
            
            let stepsInActiveWorkout = calculateStepsInActivePeriods(
                stepSamples: allStepSamples,
                activePeriods: activePeriods
            )
            
            guard stepsInActiveWorkout > 0, totalActiveDuration > 0 else {
                return nil
            }
            
            // Calculate cadence as steps per minute
            let activeMinutes = totalActiveDuration / 60.0
            let cadence = stepsInActiveWorkout / activeMinutes
            
            return cadence
            
        } catch {
            return nil
        }
    }
    
    /// Calculates steps that occurred during active workout periods, avoiding double-counting
    /// - Parameters:
    ///   - stepSamples: All step count samples
    ///   - activePeriods: Active workout periods (excluding pauses)
    /// - Returns: Total steps during active periods
    private func calculateStepsInActivePeriods(stepSamples: [HKQuantitySample], activePeriods: [DateInterval]) -> Double {
        var totalSteps: Double = 0
        var processedTimeRanges: [DateInterval] = []
        
        for activePeriod in activePeriods {
            // Find step samples that overlap with this active period
            let overlappingSamples = stepSamples.filter { sample in
                let sampleInterval = DateInterval(start: sample.startDate, end: sample.endDate)
                return sampleInterval.intersects(activePeriod)
            }
            
            for sample in overlappingSamples {
                let sampleInterval = DateInterval(start: sample.startDate, end: sample.endDate)
                let intersection = activePeriod.intersection(with: sampleInterval)
                
                if let intersection = intersection {
                    // Check if we've already processed this time range
                    let alreadyProcessed = processedTimeRanges.contains { processed in
                        processed.intersects(intersection)
                    }
                    
                    if !alreadyProcessed {
                        // Calculate proportion of steps for this intersection
                        let sampleDuration = sampleInterval.duration
                        let intersectionDuration = intersection.duration
                        let proportion = intersectionDuration / sampleDuration
                        
                        let sampleSteps = sample.quantity.doubleValue(for: HKUnit.count())
                        let proportionalSteps = sampleSteps * proportion
                        
                        totalSteps += proportionalSteps
                        processedTimeRanges.append(intersection)
                    }
                }
            }
        }
        
        return totalSteps
    }
    
    /// Gets active workout periods excluding paused time
    /// - Parameter workout: The HKWorkout to analyze
    /// - Returns: Array of active time periods
    private func getActiveWorkoutPeriods(for workout: HKWorkout) -> [DateInterval] {
        guard let events = workout.workoutEvents, !events.isEmpty else {
            // No pause/resume events, return entire workout duration
            return [DateInterval(start: workout.startDate, end: workout.endDate)]
        }
        
        var activePeriods: [DateInterval] = []
        var currentStart = workout.startDate
        var isPaused = false
        
        // Sort events by start time
        let sortedEvents = events.sorted { $0.dateInterval.start < $1.dateInterval.start }
        
        for event in sortedEvents {
            let eventTime = event.dateInterval.start
            
            if event.type == .pause && !isPaused {
                // End current active period
                activePeriods.append(DateInterval(start: currentStart, end: eventTime))
                isPaused = true
            } else if event.type == .resume && isPaused {
                // Start new active period
                currentStart = eventTime
                isPaused = false
            }
        }
        
        // Add final active period if not paused at the end
        if !isPaused && currentStart < workout.endDate {
            activePeriods.append(DateInterval(start: currentStart, end: workout.endDate))
        }
        
        return activePeriods
    }
    
    /// Fetches step count samples for a specific time period
    /// - Parameters:
    ///   - startDate: Start of the time period
    ///   - endDate: End of the time period
    /// - Returns: Array of step count samples
    private func fetchStepCountSamples(startDate: Date, endDate: Date) async throws -> [HKQuantitySample] {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw WorkoutError.failedQuery
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: stepCountType,
                predicate: predicate,
                limit: 0,
                sortDescriptors: [dateSortDescriptor]
            ) { (query, results, error) in
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
    
    func fetchWorkoutAdditionalData(from workout: HKWorkout) async -> WorkoutDetails? {
        do {
            async let cadence = fetchRunningCadence(from: workout)
            
            async let locationSamples = fetchWorkoutRoute(from: workout)
            async let heartRateSamples = fetchSamplesForUnit(from: workout, for: .heartRate)
            async let distanceSamples = fetchSamplesForUnit(
                from: workout,
                for: getDistanceType(for: workout.workoutActivityType)
            )
            
            let (cd, ls, hs, ds) = try await (cadence, locationSamples, heartRateSamples, distanceSamples)
            
            // Generate running splits using distance samples with optional elevation data from locations
            let splits = generateRunningSplits(from: ds, locations: ls, for: workout)
            
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
        
        return workouts.compactMap { workout -> Workout? in
            return Workout(
                type: sport,
                workout: workout
            )
        }
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
}
