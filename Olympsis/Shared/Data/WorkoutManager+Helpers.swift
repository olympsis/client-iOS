//
//  WorkoutManager+Helpers.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/22/25.
//

import HealthKit
import Foundation

extension WorkoutManager {
    
    /// Builds a date predicate for fetching workouts
    /// - Parameters:
    ///     - dateRange: a date interval consisting of a start and end date
    ///     - cursor: for pagination we keep track of the start date of the last workout fetched
    ///
    /// - Returns: an optional predicate for both of those dates combined
    func buildDatePredicate(dateRange: DateInterval?, cursor: Date?) -> NSPredicate? {
        var predicates: [NSPredicate] = []
        
        if let dateRange = dateRange {
            predicates.append(HKQuery.predicateForSamples(
                withStart: dateRange.start,
                end: dateRange.end,
                options: .strictStartDate
            ))
        }
        
        if let cursor = cursor {
            // For pagination - fetch workouts before the cursor date
            predicates.append(NSPredicate(
                format: "%K < %@",
                HKSampleSortIdentifierStartDate,
                cursor as NSDate
            ))
        }
        
        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    /// Get cadence type for workout activity
    /// - Parameters:
    ///     - activityType: the workout activity type
    ///
    /// - Returns: the cadence type from a `HKQuantityTypeIdentifier`
    func getCadenceType(for activityType: HKWorkoutActivityType) -> HKQuantityTypeIdentifier {
        switch activityType {
        case .running, .walking:
            return .runningStrideLength  // We'll calculate from this
        case .cycling, .handCycling:
            return .cyclingCadence
        default:
            return .stepCount  // Fallback
        }
    }
    
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
    
}
