//
//  ActivityManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import os
import SwiftUI
import HealthKit
import Foundation

class WorkoutManager: NSObject, ObservableObject {
    
    @Published var workouts = [Workout]()
    @Published var samples: [HKSample] = []
    @Published var events: [HKWorkoutEvent] = []
    
    @Published var selectedSport: SPORTS? {
        didSet {
            Task {
                await MainActor.run {
                    guard let sport = selectedSport else { return }
                    selectedWorkout = sport.getWorkoutActivityType()
                }
            }
        }
    }
    
    @Published var selectedWorkout: HKWorkoutActivityType?
    @Published var workout: HKWorkout?
    
    @Published var state: WORKOUT_STATES = .pending
    @Published var viewState: LOADING_STATE = .pending
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            Task {
                await MainActor.run {
                    if showingSummaryView {
                        selectedSport = nil
                        selectedWorkout = nil
                    }
                }
            }
        }
    }
    
    @Published var isProcessingWorkout: Bool = false
    
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    
    @Published var unit: UnitLength = Locale.current.measurementSystem == "Metric" ? UnitLength.kilometers : UnitLength.miles
    
    
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    
    #if os(watchOS)
    var builder: HKLiveWorkoutBuilder?
    #endif
    
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
        HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    ]
    
    private var log: Logger = Logger(subsystem: "com.olympsis.watchkit", category: "activity_manager")
    
    func checkAuthorizationStatus() -> Bool {
        let status = healthStore.authorizationStatus(for: .workoutType())
        if status == .sharingAuthorized {
            return true
        } else {
            return false
        }
    }
    
    @MainActor
    func requestHealthStoreAuthorization() async {
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            log.error("Failed to request health store authorization \(error.localizedDescription, privacy: .public)")
            return
        }
    }
    
    func buildWorkout(_ workout: HKWorkoutActivityType, location: HKWorkoutSessionLocationType) {
        let configuration: HKWorkoutConfiguration = {
            let config = HKWorkoutConfiguration()
            config.activityType = workout
            config.locationType = location
            return config
        }()
        
        do {
            #if os(watchOS)
            session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            builder = session?.associatedWorkoutBuilder()
            #endif
        } catch {
            log.error("Failed to start workout session: \(error.localizedDescription, privacy: .public)")
            return
        }
        
        #if os(watchOS)
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        #endif
        
        session?.delegate = self
        
        #if os(watchOS)
        builder?.delegate = self
        #endif
    }
    
    /// Prepares a workout and resets and cleans up session data
    func prepareWorkout() {
        session?.prepare()
    }
    
    /// Starts a workout
    func startWorkout() async {
        let startDate = Date()
        
        do {
            session?.startActivity(with: startDate)
            #if os(watchOS)
            try await builder?.beginCollection(at: startDate)
            #endif
        } catch {
            log.error("Failed to start collecting data from workout: \(error.localizedDescription, privacy: .public)")
            return
        }
    }
    
    /// Pauses a workout
    func pauseWorkout() {
        session?.pause()
    }
    
    /// Resumes a workout
    func resumeWorkout() {
        session?.resume()
    }
    
    /// Stops a workoutout
    func stopWorkout() {
        // If a workout is less than a minute we should not record it
        #if os(watchOS)
        if Double(builder?.elapsedTime ?? 0) < 60 {
            guard session != nil else {
                return
            }
            session?.stopActivity(with: session?.currentActivity.startDate)
            resetWorkout()
            state = .ended
            log.info("Workout ended early")
        }
        #endif
        session?.end()
    }
    
    /// Resets all of the data around workouts
    func resetWorkout() {
        if let workout,
           let selectedSport  {
            if unit == UnitLength.kilometers {
                let distance = workout.statistics(for:
                    HKQuantityType.init(.distanceWalkingRunning))?
                        .sumQuantity()?
                        .doubleValue(for: .meter()) ?? 0
                let conversion = (distance / 1000)
                let work =  Workout(id: UUID(), type: selectedSport, startDate: workout.startDate, endDate: workout.endDate, averageHeartRate: 0, caloriesBurned: 0, totalDistanceTraveled: conversion)
                workouts.append(work)
            } else {
                let distance = workout.statistics(for:
                    HKQuantityType.init(.distanceWalkingRunning))?
                        .sumQuantity()?
                        .doubleValue(for: .mile()) ?? 0
                let work = Workout(id: UUID(), type: selectedSport, startDate: workout.startDate, endDate: workout.endDate, averageHeartRate: 0, caloriesBurned: 0, totalDistanceTraveled: distance)
                workouts.append(work)
            }
        }
        
        selectedSport = nil
        selectedWorkout = nil
        #if os(watchOS)
        builder = nil
        #endif
        session = nil
        workout = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
    }
    
    @MainActor
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let _ = statistics.maximumQuantity()
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                if self.unit == UnitLength.kilometers {
                    self.distance = statistics.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
                    
                } else {
                    self.distance = statistics.sumQuantity()?.doubleValue(for: HKUnit.mile()) ?? 0
                }
            default:
                return
            }
        }
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate {
    
    @MainActor
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .notStarted:
            Task {
                await MainActor.run {
                    state = .pending
                    self.log.info("Workout state changed -> PENDING")
                }
            }
        case .prepared:
            Task {
                await MainActor.run {
                    self.log.info("Workout state changed -> PREPARED")
                }
            }
        case .running:
            Task {
                await MainActor.run {
                    state = .active
                    self.log.info("Workout state changed -> ACTIVE")
                }
            }
        case .ended:
            Task {
                Task {
                    do {
                        await MainActor.run {
                            self.isProcessingWorkout = true
                        }
                        #if os(watchOS)
                        try await builder?.endCollection(at: date)
                        let workout = try await self.builder?.finishWorkout()
                        #endif
                        await MainActor.run {
                            self.workout = workout
                            self.state = .ended
                            self.isProcessingWorkout = false
                            self.showingSummaryView = true
                            self.log.info("Workout state changed -> ENDED")
                        }
                    } catch {
                        await MainActor.run {
                            self.state = .ended
                            self.log.error("Failed to finish workout: \(error.localizedDescription, privacy: .public)")
                        }
                    }
                }
            }
        case .paused:
            Task {
                await MainActor.run {
                    state = .paused
                    self.log.info("Workout state changed -> PAUSED")
                }
            }
        case .stopped:
            Task {
                await MainActor.run {
                    state = .paused
                    self.log.info("Workout state changed -> STOPPED")
                }
            }
        @unknown default:
            self.log.error("Workout state changed -> UNKNOWN STATE")
            return
        }
        
        return
    }
    
    @MainActor
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
        log.error("Workout session failed: \(error.localizedDescription, privacy: .public)")
        return
    }
    
    #if os(watchOS)
    @MainActor
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }

            let statistics = workoutBuilder.statistics(for: quantityType)

            updateForStatistics(statistics)
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    #endif
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didDisconnectFromRemoteDeviceWithError error: Error?) {
        log.log("\(#function): \(error)")
    }
    
    /**
     In iOS, the sample app can go into the background and become suspended.
     When suspended, HealthKit gathers the data coming from the remote session.
     When the app resumes, HealthKit sends an array containing all the data objects it has accumulated to this delegate method.
     The data objects in the array appear in the order that the local system received them.

     On watchOS, the workout session keeps the app running even if it is in the background; however, the system can
     temporarily suspend the app — for example, if the app uses an excessive amount of CPU in the background.
     While suspended, HealthKit caches the incoming data objects and delivers an array of data objects when the app resumes, just like in the iOS app.
     */
    func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didReceiveDataFromRemoteWorkoutSession data: [Data]) {
        log.log("\(#function): \(data.debugDescription)")
        Task { @MainActor in
//            do {
//                for anElement in data {
////                    try handleReceivedData(anElement)
//                }
//            } catch {
//                log.log("Failed to handle received data: \(error))")
//            }
        }
    }
}

#if os(watchOS)
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    
}
#endif


extension WorkoutManager {
    
    func fetchWorkoutsHistory(in datePredicate: String?) async {
        guard checkAuthorizationStatus() else {
            return
        }
        await MainActor.run {
            self.viewState = .loading
        }
        let workouts = await fetchAllWorkoutHistory(in: datePredicate)
        await MainActor.run {
            self.workouts = workouts
        }
        await MainActor.run {
            self.viewState = .pending
        }
    }
    
    func fetchAllWorkoutHistory(in datePredicate: String?) async -> [Workout] {
        var workouts = [Workout]()
        await withTaskGroup(of: [Workout].self) { group in
            for sport in SUPPORTED_SPORTS.allCases {
                group.addTask {
                    return await self.fetchWorkoutHistory(for: sport.workoutActivityType, in: datePredicate)
                }
            }
            
            for await results in group {
                workouts.append(contentsOf: results)
            }
        }
        return workouts
    }
    
    func fetchWorkoutHistory(for workoutType: HKWorkoutActivityType, in datePredicate: String?) async -> [Workout] {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: workoutType)
        
        var combinations = [NSPredicate]()
        combinations.append(workoutPredicate)
        if let datePredicate {
            combinations.append(NSPredicate(format: datePredicate))
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: combinations)

        do {
            let workouts = try await fetchWorkouts(type: workoutType, predicate: predicate)
            var _workouts: [Workout] = []
            
            await withTaskGroup(of: Workout?.self) { group in
                for workout in workouts {
                    group.addTask {
                        async let avgHeartRate = self.fetchAverageForUnit(from: workout, for: .heartRate)
                        async let caloriesBurned = self.fetchAverageForUnit(from: workout, for: .activeEnergyBurned)
                        async let distanceTraveled = self.fetchAverageForUnit(from: workout, for: .distanceWalkingRunning)

                        do {
                            let workoutData = try await (
                                avgHeartRate,
                                caloriesBurned,
                                distanceTraveled
                            )

                            guard let activity = sportFromActivityType(activity: workoutType) else {
                                throw WorkoutError.failedQuery
                            }
                            
                            return Workout(
                                id: workout.uuid,
                                type: activity,
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

                
                for await result in group {
                    if let workout = result {
                        _workouts.append(workout)
                    }
                }
            }
            
            return _workouts
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
        
        return []
    }
    
    func fetchWorkouts(type: HKWorkoutActivityType, predicate: NSPredicate) async throws -> [HKWorkout] {
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
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
    
    func fetchAverageForUnit(from workout: HKWorkout, for quantityType: HKQuantityTypeIdentifier) async throws -> Double {
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let type = HKQuantityType.quantityType(forIdentifier: quantityType)!
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let unit = {
            if quantityType == .heartRate {
                return HKUnit.count().unitDivided(by: HKUnit.minute())
            } else if quantityType == .activeEnergyBurned {
                return HKUnit.kilocalorie()
            } else {
                if self.unit == UnitLength.miles {
                    return HKUnit.mile()
                } else {
                    return HKUnit.meter()
                }
            }
        }()
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let samples = results as? [HKQuantitySample] {
                    let average = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: unit) }
                    continuation.resume(returning: average)
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

extension WorkoutManager {
    var weekPredicate: NSPredicate {
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now)
        let daysToMonday = (currentWeekday == 1) ? 7 : currentWeekday - 2  // 1 is Sunday, so we need to go back 6 days to get to Monday
        let startOfWeek = calendar.date(byAdding: .day, value: -daysToMonday, to: now)!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        return NSPredicate(format: "startDate >= %@ AND endDate <= %@", startOfWeek as CVarArg, endOfWeek as CVarArg)
    }
    
    var monthPredicate: NSPredicate {
        let now = Date()
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

        return NSPredicate(format: "startDate >= %@ AND endDate <= %@", startOfMonth as CVarArg, endOfMonth as CVarArg)
    }
    
    var yearPredicate: NSPredicate {
        let now = Date()
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))!
        let endOfYear = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear)!

        return NSPredicate(format: "startDate >= %@ AND endDate <= %@", startOfYear as CVarArg, endOfYear as CVarArg)
    }
}
