//
//  WorkoutManager.swift
//  Olympsis
//
//  Created by Joel on 10/15/23.
//

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
    
    var workouts = [Workout]()
    
    private var anchor: HKQueryAnchor?
    private var selectedSport = 0
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
    
    private let log = Logger(subsystem: "com.josephlabs.olympsis", category: "workout_manager")
    
    func requestHealthStoreAuthorization() async {
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            log.error("\(error)")
        }
    }
    
    func setUpOutdoorWalkingConfiguration() {
        configuration.activityType = .walking
        configuration.locationType = .outdoor
    }
    
    func setUpOutdoorRunningConfiguration() {
        configuration.activityType = .running
        configuration.locationType = .outdoor
    }
    
    func startWorkoutSession() {}
    
    func loadWeeklyHistory() async {
//        var _anchor: HKQueryAnchor? = nil
//        let stepType = HKQuantityType(.stepCount)
//        
//        if let a = anchor {
//            _anchor = a
//        }
//        var results: HKAnchoredObjectQueryDescriptor<HKQuantitySample>.Result
//        
//        do {
//            repeat {
//                // Create a query descriptor that reads a batch
//                // of 100 matching samples.
//                let anchorDescriptor =
//                HKAnchoredObjectQueryDescriptor(
//                    predicates: [.quantitySample(type: stepType)],
//                    anchor: anchor,
//                    limit: 100
//                )
//
//
//                results = try await anchorDescriptor.result(for: healthStore)
//                anchor = results.newAnchor
//                
//                // Process the batch of results here.
//                
//            } while (results.addedSamples != []) && (results.deletedObjects != [])
//        } catch {
//            print ("failed to load weekly history \(error)")
//        }
    }
    
    func loadWeekyRunHistory() async {
        let workoutType = HKWorkoutActivityType.running
        let workoutPredicate = HKQuery.predicateForWorkouts(with: workoutType)
        
        let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())
        let endDate = Date()

        let datePredicate = NSPredicate(format: "startDate >= %@ AND endDate <= %@", startDate! as CVarArg, endDate as CVarArg)
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, datePredicate])
        
        do {
            let resp = try await fetchWorkouts(type: workoutType, predicate: predicate, dateSortDescriptor: dateSortDescriptor)
            for workout in resp {
                let avgHeartRate = try await fetchAverageHeartRateForWorkout(workout: workout, dateSortDescriptor: dateSortDescriptor)
                let caloriesBurned = try await fetchCaloriesBurnedForWorkout(workout: workout, dateSortDescriptor: dateSortDescriptor)
                let distanceTraveled = try await fetchDistanceWalkedRanForWorkout(workout: workout, dateSortDescriptor: dateSortDescriptor)
                self.workouts.append(Workout(id: workout.uuid, type: .running, startDate: workout.startDate, endDate: workout.endDate, averageHeartRate: avgHeartRate, caloriesBurned: caloriesBurned, totalDistanceTraveled: distanceTraveled))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadWeekyWalkHistory() async {
        let workoutType = HKWorkoutActivityType.walking
        let workoutPredicate = HKQuery.predicateForWorkouts(with: workoutType)
        
        let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())
        let endDate = Date()

        let datePredicate = NSPredicate(format: "startDate >= %@ AND endDate <= %@", startDate! as CVarArg, endDate as CVarArg)
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, datePredicate])
        
        do {
            let startTime = Date()
            let resp = try await fetchWorkouts(type: workoutType, predicate: predicate, dateSortDescriptor: dateSortDescriptor)
            let endTime = Date()
            print(endTime.timeIntervalSince(startTime))
            for workout in resp {
                let avgHeartRate = try await fetchAverageHeartRateForWorkout(workout: workout, dateSortDescriptor: dateSortDescriptor)
                let caloriesBurned = try await fetchCaloriesBurnedForWorkout(workout: workout, dateSortDescriptor: dateSortDescriptor)
                let distanceTraveled = try await fetchDistanceWalkedRanForWorkout(workout: workout, dateSortDescriptor: dateSortDescriptor)
                self.workouts.append(Workout(id: workout.uuid, type: .walking, startDate: workout.startDate, endDate: workout.endDate, averageHeartRate: avgHeartRate, caloriesBurned: caloriesBurned, totalDistanceTraveled: distanceTraveled))
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// fetches all of the workouts in the last week
    func fetchWorkouts(type: HKWorkoutActivityType, predicate: NSPredicate, dateSortDescriptor: NSSortDescriptor) async throws -> [HKWorkout] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: 20, sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let workouts = results as? [HKWorkout] {
                    continuation.resume(returning: workouts)
                } else {
                    continuation.resume(throwing: WorkoutError.failedQuery)                }
            }
            healthStore.execute(query)
        }
    }
    
    /// Calculates the average heart rate for a workout
    func fetchAverageHeartRateForWorkout(workout: HKWorkout, dateSortDescriptor: NSSortDescriptor) async throws -> Double {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: heartRateType, predicate: workoutPredicate, limit: 0, sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let heartRateSamples = results as? [HKQuantitySample] {
                    var totalHeartRate = 0.0
                    for sample in heartRateSamples {
                        totalHeartRate += sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                    }
                    let averageHeartRate = totalHeartRate / Double(heartRateSamples.count)
                    continuation.resume(returning: averageHeartRate)
                } else {
                    continuation.resume(throwing: WorkoutError.failedQuery)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    /// Calculates the total calories burned for a workout
    func fetchCaloriesBurnedForWorkout(workout: HKWorkout, dateSortDescriptor: NSSortDescriptor) async throws -> Double {
        let caloriesRateType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let caloricPredicate = HKQuery.predicateForObjects(from: workout)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: caloriesRateType, predicate: caloricPredicate, limit: 0, sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let caloricRateSamples = results as? [HKQuantitySample] {
                    var totalCaloriesBurned = 0.0
                    for sample in caloricRateSamples {
                        totalCaloriesBurned += sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                    }
                    continuation.resume(returning: totalCaloriesBurned)
                } else {
                    continuation.resume(throwing: WorkoutError.failedQuery)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
    /// Calculates the total distance walkred/ran for a workout
    func fetchDistanceWalkedRanForWorkout(workout: HKWorkout, dateSortDescriptor: NSSortDescriptor) async throws -> Double {
        let distanceTraveledType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let distancePredicate = HKQuery.predicateForObjects(from: workout)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: distanceTraveledType, predicate: distancePredicate, limit: 0, sortDescriptors: [dateSortDescriptor]) { (query, results, error) in
                if let distanceSamples = results as? [HKQuantitySample] {
                    var totalDistanceTraveled = 0.0
                    for sample in distanceSamples {
                        totalDistanceTraveled += sample.quantity.doubleValue(for: HKUnit.mile())
                    }
                    continuation.resume(returning: totalDistanceTraveled)
                } else {
                    continuation.resume(throwing: WorkoutError.failedQuery)
                }
            }
            self.healthStore.execute(query)
        }
    }
    
}

