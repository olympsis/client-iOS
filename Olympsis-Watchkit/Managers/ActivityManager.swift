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

class ActivityManager: NSObject, ObservableObject, HKLiveWorkoutBuilderDelegate {
    
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
    var builder: HKLiveWorkoutBuilder?
    
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
            session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            builder = session?.associatedWorkoutBuilder()
        } catch {
            log.error("Failed to start workout session: \(error.localizedDescription, privacy: .public)")
            return
        }
        
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        
        session?.delegate = self
        builder?.delegate = self
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
            try await builder?.beginCollection(at: startDate) // TODO: - CODE FAILS HERE
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
        if Double(builder?.elapsedTime ?? 0) < 60 {
            guard session != nil else {
                return
            }
            session?.stopActivity(with: session?.currentActivity.startDate)
            resetWorkout()
            state = .ended
            log.info("Workout ended early")
        }
        session?.end()
    }
    
    /// Resets all of the data around workouts
    func resetWorkout() {
        selectedSport = nil
        selectedWorkout = nil
        builder = nil
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
                let heartHistory = statistics.maximumQuantity()
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

extension ActivityManager: HKWorkoutSessionDelegate {
    
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
                        try await builder?.endCollection(at: date)
                        let workout = try await self.builder?.finishWorkout()
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
    
    @MainActor 
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }

            let statistics = workoutBuilder.statistics(for: quantityType)

            updateForStatistics(statistics)
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
