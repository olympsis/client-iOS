////
////  WorkoutManager.swift
////  Olympsis
////
////  Created by Joel on 10/15/23.
////

import os
import SwiftUI
import HealthKit
import WorkoutKit
import Foundation

enum WorkoutError: Error {
    case unknown
    case failedQuery
}

@MainActor
class WorkoutManager: ObservableObject {
    
    @Published var workouts = [Workout]()
    
    @Published var selectedSport: SPORTS = .running
    @Published var state: LOADING_STATE = .pending
    @Published var workoutState: WORKOUT_STATES = .pending
    
    @Published var samples: [HKSample] = []
    @Published var events: [HKWorkoutEvent] = []
    
    // Live workout data
    @Published var pace: Double = 0
    @Published var heartRate: Int = 0
    @Published var ellapsedTime: Int = 0
    @Published var distanceTraveled: Double = 0
    @Published var elevation: Double = 0
    @Published var caloriesBurned: Int = 0
    
    
    private var anchor: HKQueryAnchor?
    private let healthStore = HKHealthStore()
    private let configuration = HKWorkoutConfiguration()
    
    private var typesToShare: Set = [
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
    ]
    
    private var typesToRead: Set = [
        HKSampleType.workoutType(),
        HKSampleType.activitySummaryType(),
        HKSampleType.characteristicType(forIdentifier: .biologicalSex)!,
        HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    ]
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "workout_manager")
    
    func requestHealthStoreAuthorization() async {
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            log.error("\(error)")
        }
    }
    
    func setUpOutdoorRunningConfiguration() {
        configuration.activityType = .running
        configuration.locationType = .outdoor
    }
    
    func setUpIndoorRunningConfiguration() {
        configuration.activityType = .running
        configuration.locationType = .indoor
    }
    
    func startWorkout() async {
        
    }
    
    func pauseWorkout() async {
        
    }
    
    func stopWorkout() async {
        
    }
    
    func setUpWorkoutSession() -> HKWorkoutBuilder {
        return HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: configuration,
            device: .local()
        )
    }
    
    func startWorkoutSession(builder: HKWorkoutBuilder) async throws {
        try await builder.beginCollection(at: Date())
        try await builder.addSamples(samples)
        try await builder.addWorkoutEvents(events)
    }
    
    func pauseWorkoutSession(builder: HKWorkoutBuilder) async throws {
        
    }
    
    func stopWokroutSession(builder: HKWorkoutBuilder) async throws {
        
    }
    
    @MainActor
    func loadWeeklyRunHistory() {
        Task {
            state = .loading
            let workoutType = HKWorkoutActivityType.running
            let workoutPredicate = HKQuery.predicateForWorkouts(with: workoutType)

            let now = Date()
            let calendar = Calendar.current
            let currentWeekday = calendar.component(.weekday, from: now)
            let daysToMonday = (currentWeekday == 1) ? 7 : currentWeekday - 2  // 1 is Sunday, so we need to go back 6 days to get to Monday
            let startOfWeek = calendar.date(byAdding: .day, value: -daysToMonday, to: now)!
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

            let datePredicate = NSPredicate(format: "startDate >= %@ AND endDate <= %@", startOfWeek as CVarArg, endOfWeek as CVarArg)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, datePredicate])

            do {
                let workouts = try await fetchWorkouts(type: workoutType, predicate: predicate)
                
                await withTaskGroup(of: Workout?.self) { group in
                    for workout in workouts {
                        group.addTask {
                            async let avgHeartRate = self.fetchAverageHeartRateForWorkout(workout: workout)
                            async let caloriesBurned = self.fetchCaloriesBurnedForWorkout(workout: workout)
                            async let distanceTraveled = self.fetchDistanceWalkedRanForWorkout(workout: workout)

                            do {
                                let workoutData = try await (
                                    avgHeartRate,
                                    caloriesBurned,
                                    distanceTraveled
                                )

                                return Workout(
                                    id: workout.uuid,
                                    type: .running,
                                    startDate: workout.startDate,
                                    endDate: workout.endDate,
                                    averageHeartRate: workoutData.0,
                                    caloriesBurned: workoutData.1,
                                    totalDistanceTraveled: workoutData.2
                                )
                            } catch {
                                self.log.error("Failed to fetch data for workout \(workout.uuid): \(error.localizedDescription)")
                                return nil
                            }
                        }
                    }

                    var _workouts: [Workout] = []
                    for await result in group {
                        if let workout = result {
                            _workouts.append(workout)
                        }
                    }
                    
                    self.workouts = _workouts
                    state = .success
                }
            } catch HKError.errorNoData {
                log.error("No data")
            } catch HKError.errorHealthDataUnavailable {
                log.error("Data unavailable")
            } catch HKError.errorHealthDataRestricted {
                log.error("Data restricted")
            } catch HKError.errorInvalidArgument {
                log.error("Invalid argument")
            } catch HKError.errorAuthorizationDenied {
                log.error("Authorization Denied")
            } catch HKError.errorAuthorizationNotDetermined {
                log.error("Authorization Unknown")
            } catch HKError.errorRequiredAuthorizationDenied {
                log.error("Authorization Denied")
            } catch HKError.errorDatabaseInaccessible {
                log.error("Database Inaccessible")
            } catch {
                log.error("Failed to load weekly run history: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func loadMonthlyRunHistory() {
        Task {
            state = .loading
            let workoutType = HKWorkoutActivityType.running
            let workoutPredicate = HKQuery.predicateForWorkouts(with: workoutType)

            let now = Date()
            let calendar = Calendar.current
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

            let datePredicate = NSPredicate(format: "startDate >= %@ AND endDate <= %@", startOfMonth as CVarArg, endOfMonth as CVarArg)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, datePredicate])

            do {
                let workouts = try await fetchWorkouts(type: workoutType, predicate: predicate)
                
                await withTaskGroup(of: Workout?.self) { group in
                    for workout in workouts {
                        group.addTask {
                            async let avgHeartRate = self.fetchAverageHeartRateForWorkout(workout: workout)
                            async let caloriesBurned = self.fetchCaloriesBurnedForWorkout(workout: workout)
                            async let distanceTraveled = self.fetchDistanceWalkedRanForWorkout(workout: workout)

                            do {
                                let workoutData = try await (
                                    avgHeartRate,
                                    caloriesBurned,
                                    distanceTraveled
                                )

                                return Workout(
                                    id: workout.uuid,
                                    type: .running,
                                    startDate: workout.startDate,
                                    endDate: workout.endDate,
                                    averageHeartRate: workoutData.0,
                                    caloriesBurned: workoutData.1,
                                    totalDistanceTraveled: workoutData.2
                                )
                            } catch {
                                self.log.error("Failed to fetch data for workout \(workout.uuid): \(error.localizedDescription)")
                                return nil
                            }
                        }
                    }

                    var _workouts: [Workout] = []
                    for await result in group {
                        if let workout = result {
                            _workouts.append(workout)
                        }
                    }
                    
                    self.workouts = _workouts
                    state = .success
                }
            } catch HKError.errorNoData {
                log.error("No data")
            } catch HKError.errorHealthDataUnavailable {
                log.error("Data unavailable")
            } catch HKError.errorHealthDataRestricted {
                log.error("Data restricted")
            } catch HKError.errorInvalidArgument {
                log.error("Invalid argument")
            } catch HKError.errorAuthorizationDenied {
                log.error("Authorization Denied")
            } catch HKError.errorAuthorizationNotDetermined {
                log.error("Authorization Unknown")
            } catch HKError.errorRequiredAuthorizationDenied {
                log.error("Authorization Denied")
            } catch HKError.errorDatabaseInaccessible {
                log.error("Database Inaccessible")
            } catch {
                log.error("Failed to load monthly run history: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    func loadYearlyRunHistory() {
        Task {
            state = .loading
            let workoutType = HKWorkoutActivityType.running
            let workoutPredicate = HKQuery.predicateForWorkouts(with: workoutType)

            let now = Date()
            let calendar = Calendar.current
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
            let endOfYear = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear)!

            let datePredicate = NSPredicate(format: "startDate >= %@ AND endDate <= %@", startOfYear as CVarArg, endOfYear as CVarArg)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, datePredicate])

            do {
                let workouts = try await fetchWorkouts(type: workoutType, predicate: predicate)
                
                await withTaskGroup(of: Workout?.self) { group in
                    for workout in workouts {
                        group.addTask {
                            async let avgHeartRate = self.fetchAverageHeartRateForWorkout(workout: workout)
                            async let caloriesBurned = self.fetchCaloriesBurnedForWorkout(workout: workout)
                            async let distanceTraveled = self.fetchDistanceWalkedRanForWorkout(workout: workout)

                            do {
                                let workoutData = try await (
                                    avgHeartRate,
                                    caloriesBurned,
                                    distanceTraveled
                                )

                                return Workout(
                                    id: workout.uuid,
                                    type: .running,
                                    startDate: workout.startDate,
                                    endDate: workout.endDate,
                                    averageHeartRate: workoutData.0,
                                    caloriesBurned: workoutData.1,
                                    totalDistanceTraveled: workoutData.2
                                )
                            } catch {
                                self.log.error("Failed to fetch data for workout \(workout.uuid): \(error.localizedDescription)")
                                return nil
                            }
                        }
                    }

                    var _workouts: [Workout] = []
                    for await result in group {
                        if let workout = result {
                            _workouts.append(workout)
                        }
                    }
                    
                    self.workouts = _workouts
                    state = .success
                }
            } catch HKError.errorNoData {
                log.error("No data")
            } catch HKError.errorHealthDataUnavailable {
                log.error("Data unavailable")
            } catch HKError.errorHealthDataRestricted {
                log.error("Data restricted")
            } catch HKError.errorInvalidArgument {
                log.error("Invalid argument")
            } catch HKError.errorAuthorizationDenied {
                log.error("Authorization Denied")
            } catch HKError.errorAuthorizationNotDetermined {
                log.error("Authorization Unknown")
            } catch HKError.errorRequiredAuthorizationDenied {
                log.error("Authorization Denied")
            } catch HKError.errorDatabaseInaccessible {
                log.error("Database Inaccessible")
            } catch {
                log.error("Failed to load yearly run history: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func loadAllTimeRunHistory() {
        Task {
            state = .loading
            
            let workoutType = HKWorkoutActivityType.running
            let workoutPredicate = HKQuery.predicateForWorkouts(with: workoutType)

            let predicate = workoutPredicate

            do {
                let workouts = try await fetchWorkouts(type: workoutType, predicate: predicate)
                
                await withTaskGroup(of: Workout?.self) { group in
                    for workout in workouts {
                        group.addTask {
                            async let avgHeartRate = self.fetchAverageHeartRateForWorkout(workout: workout)
                            async let caloriesBurned = self.fetchCaloriesBurnedForWorkout(workout: workout)
                            async let distanceTraveled = self.fetchDistanceWalkedRanForWorkout(workout: workout)

                            do {
                                let workoutData = try await (
                                    avgHeartRate,
                                    caloriesBurned,
                                    distanceTraveled
                                )

                                return Workout(
                                    id: workout.uuid,
                                    type: .running,
                                    startDate: workout.startDate,
                                    endDate: workout.endDate,
                                    averageHeartRate: workoutData.0,
                                    caloriesBurned: workoutData.1,
                                    totalDistanceTraveled: workoutData.2
                                )
                            } catch {
                                self.log.error("Failed to fetch data for workout \(workout.uuid): \(error.localizedDescription)")
                                return nil
                            }
                        }
                    }

                    var _workouts: [Workout] = []
                    for await result in group {
                        if let workout = result {
                            _workouts.append(workout)
                        }
                    }
                    
                    self.workouts = _workouts
                    state = .success
                }
            } catch HKError.errorNoData {
                log.error("No data")
            } catch HKError.errorHealthDataUnavailable {
                log.error("Data unavailable")
            } catch HKError.errorHealthDataRestricted {
                log.error("Data restricted")
            } catch HKError.errorInvalidArgument {
                log.error("Invalid argument")
            } catch HKError.errorAuthorizationDenied {
                log.error("Authorization Denied")
            } catch HKError.errorAuthorizationNotDetermined {
                log.error("Authorization Unknown")
            } catch HKError.errorRequiredAuthorizationDenied {
                log.error("Authorization Denied")
            } catch HKError.errorDatabaseInaccessible {
                log.error("Database Inaccessible")
            } catch {
                log.error("Failed to load all-time run history: \(error.localizedDescription)")
            }
        }
    }
    
    /// fetches all of the workouts in the last week
    func fetchWorkouts(type: HKWorkoutActivityType, predicate: NSPredicate) async throws -> [HKWorkout] {
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
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
    
    /// Calculates the average heart rate for a workout
    func fetchAverageHeartRateForWorkout(workout: HKWorkout) async throws -> Double {
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: heartRateType, predicate: workoutPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let heartRateSamples = results as? [HKQuantitySample] {
                    let totalHeartRate = heartRateSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) }
                    let averageHeartRate = totalHeartRate / Double(heartRateSamples.count)
                    continuation.resume(returning: averageHeartRate)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: WorkoutError.failedQuery)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    /// Calculates the total calories burned for a workout
    func fetchCaloriesBurnedForWorkout(workout: HKWorkout) async throws -> Double {
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let caloriesRateType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let caloricPredicate = HKQuery.predicateForObjects(from: workout)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: caloriesRateType, predicate: caloricPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let caloricRateSamples = results as? [HKQuantitySample] {
                    let totalCaloriesBurned = caloricRateSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
                    continuation.resume(returning: totalCaloriesBurned)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: WorkoutError.failedQuery)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    /// Calculates the total distance walkred/ran for a workout
    func fetchDistanceWalkedRanForWorkout(workout: HKWorkout) async throws -> Double {
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let distanceTraveledType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let distancePredicate = HKQuery.predicateForObjects(from: workout)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: distanceTraveledType, predicate: distancePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let distanceSamples = results as? [HKQuantitySample] {
                    let totalDistanceTraveled = distanceSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.mile()) }
                    continuation.resume(returning: totalDistanceTraveled)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: WorkoutError.failedQuery)
                }
            }
            self.healthStore.execute(query)
        }
    }
}

extension [Workout] {
    
    func totalCaloriesBurned() -> Int {
        return Int(self.reduce(0.0) { $0 + $1.caloriesBurned })
    }
    
    func totalCaloriesBurnedPerDay() -> [CaloricDailyAverage] {
        let calendar = Calendar.current
        var caloriesBurnedPerDay = [0, 0, 0, 0, 0, 0, 0]
        var workoutCountPerDay = [0, 0, 0, 0, 0, 0, 0]
            
        for workout in self {
            let startDate = workout.startDate
            let weekday = calendar.component(.weekday, from: startDate)
            
            // Adjust weekday index to be 0 for Monday, 1 for Tuesday, ..., 6 for Sunday
            let index = (weekday + 5) % 7
            caloriesBurnedPerDay[index] += Int(workout.caloriesBurned)
            workoutCountPerDay[index] += 1
        }
        
        var caloricDailyAverages = [CaloricDailyAverage]()
        
        for (index, totalCalories) in caloriesBurnedPerDay.enumerated() {
            _ = workoutCountPerDay[index]
            caloricDailyAverages.append(CaloricDailyAverage(id: index, count: totalCalories))
        }
        
        return caloricDailyAverages
    }
    
    func totalCaloriesBurnedPerDayInMonth() -> [CaloricDailyAverage] {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return []
        }
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let numDays = range.count
        
        var caloriesBurnedPerDay = [Int]()
        for _ in 0..<numDays {
            caloriesBurnedPerDay.append(0)
        }
        
        for workout in self {
            let startDate = workout.startDate
            let dayOfMonth = calendar.component(.day, from: startDate) - 1 // -1 to convert to 0-based index
            caloriesBurnedPerDay[dayOfMonth] += Int(workout.caloriesBurned)
        }
        
        var caloricDailyAverages = [CaloricDailyAverage]()
        
        for (index, totalCalories) in caloriesBurnedPerDay.enumerated() {
            caloricDailyAverages.append(CaloricDailyAverage(id: index+1, count: totalCalories)) // +1 to convert back to 1-based day
        }
        
        return caloricDailyAverages
    }
    
    func monthlyAverageCaloriesBurned() -> [CaloricMonthlyAverage] {
        let calendar = Calendar.current
        var caloriesBurnedPerMonth = [Int]()
        var workoutCountPerMonth = [Int]()
        
        for _ in 0..<12 {
            caloriesBurnedPerMonth.append(0)
            workoutCountPerMonth.append(0)
        }
        
        for workout in self {
            let startDate = workout.startDate
            let month = calendar.component(.month, from: startDate) - 1 // -1 to convert to 0-based index
            caloriesBurnedPerMonth[month] += Int(workout.caloriesBurned)
            workoutCountPerMonth[month] += 1
        }
        
        var caloricMonthlyAverages = [CaloricMonthlyAverage]()
        
        for (index, totalCalories) in caloriesBurnedPerMonth.enumerated() {
            _ = workoutCountPerMonth[index]
            caloricMonthlyAverages.append(CaloricMonthlyAverage(id: index, count: totalCalories)) // +1 to convert back to 1-based month
        }
        
        return caloricMonthlyAverages
    }
}
