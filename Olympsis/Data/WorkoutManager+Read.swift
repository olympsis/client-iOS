//
//  WorkoutManager+Read.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/3/24.
//

import os
// import HealthKit
import Foundation
import CoreLocation

/* HealthKit disabled - entire file depends on HealthKit types (HKWorkout, HKQuery, HKSampleQuery, HKQuantityType, HKUnit, etc.)
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
                        do {
                            guard let activity = sportFromActivityType(activity: workoutType) else {
                                throw WorkoutError.failedQuery
                            }

                            return Workout(
                                type: activity,
                                workout: workout
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
                    if quantityType == .heartRate {
                        if let last = samples.last?.quantity.doubleValue(for: unit) {
                            continuation.resume(returning: last)
                            return
                        }
                    }
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

    func fetchSamplesForUnit(from workout: HKWorkout, for quantityType: HKQuantityTypeIdentifier) async throws -> [HKQuantitySample] {
        let dateSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let type = HKQuantityType.quantityType(forIdentifier: quantityType)!
        let predicate = HKQuery.predicateForObjects(from: workout)

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

    func fetchWorkoutRoute(from workout: HKWorkout) async throws -> [CLLocation] {
        return try await withCheckedThrowingContinuation { continuation in
            let workoutPredicate = HKQuery.predicateForObjects(from: workout)

            let query = HKSampleQuery(sampleType: HKSeriesType.workoutRoute(),
                                      predicate: workoutPredicate,
                                      limit: 0,
                                      sortDescriptors: nil) { (query, results, error) in
                if let workoutRouteSamples = results as? [HKWorkoutRoute] {
                    var locations: [CLLocation] = []

                    let group = DispatchGroup()
                    for workoutRoute in workoutRouteSamples {
                        group.enter()
                        let locationQuery = HKWorkoutRouteQuery(route: workoutRoute) { (query, routeData, done, error) in
                            if let routeData = routeData {
                                locations.append(contentsOf: routeData)
                            }
                            if done {
                                group.leave()
                            }
                        }
                        self.healthStore.execute(locationQuery)
                    }

                    group.notify(queue: .main) {
                        continuation.resume(returning: locations)
                    }
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
*/
