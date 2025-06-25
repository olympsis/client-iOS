//
//  WorkoutUtils.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/24/25.
//

import HealthKit
import Foundation

/// Gets distance for workout type
/// - Parameters:
///     - activityType: the type of activity we want distance for
///
/// - Returns: Returns the HealthKit quantity type needed to get distance
func getDistanceType(for activityType: HKWorkoutActivityType) -> HKQuantityTypeIdentifier {
    switch activityType {
    case .cycling, .handCycling:
        return .distanceCycling
    case .swimming:
        return .distanceSwimming
    case .walking, .running, .hiking, .stairClimbing:
        return .distanceWalkingRunning
    case .wheelchairWalkPace, .wheelchairRunPace:
        return .distanceWheelchair
    case .downhillSkiing, .crossCountrySkiing, .snowboarding:
        return .distanceDownhillSnowSports
    default:
        return .distanceWalkingRunning // Default fallback
    }
}


func getDistanceQuantityType(for workout: HKWorkout) -> HKQuantityType? {
    switch workout.workoutActivityType {
    case .americanFootball,
            .australianFootball,
            .baseball,
            .walking,
            .running,
            .hiking,
            .cricket,
            .stairClimbing,
            .volleyball,
            .basketball,
            .discSports,
            .golf,
            .rugby,
            .softball,
            .soccer,
            .handball,
            .climbing,
            .lacrosse:
        return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
    case .tennis, .pickleball, .squash, .badminton, .tableTennis, .racquetball, .paddleSports:
        if #available(iOS 18.0, *) {
            return HKQuantityType.quantityType(forIdentifier: .distancePaddleSports)
        } else {
            return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        }
    case .cycling, .elliptical:
        return HKQuantityType.quantityType(forIdentifier: .distanceCycling)
    case .hockey, .skatingSports:
        if #available(iOS 18.0, *) {
            return HKQuantityType.quantityType(forIdentifier: .distanceSkatingSports)
        } else {
            return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        }
    case .rowing:
        if #available(iOS 18.0, *) {
            return HKQuantityType.quantityType(forIdentifier: .distanceRowing)
        } else {
            return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        }
    case .downhillSkiing, .crossCountrySkiing, .snowboarding, .snowSports:
        return HKQuantityType.quantityType(forIdentifier: .distanceDownhillSnowSports)
    case .swimming, .waterPolo, .waterFitness, .waterSports:
        return HKQuantityType.quantityType(forIdentifier: .distanceSwimming)
    case .stairs, .stepTraining:
        return HKQuantityType.quantityType(forIdentifier: .stepCount)
    default:
        return nil
    }
}

//HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
