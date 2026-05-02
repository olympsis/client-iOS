//
//  ActivityManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import os
import SwiftUI
// import HealthKit
import Foundation
import CoreLocation

/* HealthKit disabled - entire class depends on HealthKit types
   (HKHealthStore, HKWorkoutSession, HKWorkoutRouteBuilder, HKWorkout,
    HKWorkoutActivityType, HKSample, HKWorkoutEvent, HKQuantityType, HKUnit, etc.)

class WorkoutManager: NSObject, ObservableObject {

    @Published var workouts = [Workout]()
    @Published var samples: [HKSample] = []
    @Published var events: [HKWorkoutEvent] = []
    @Published var manager = CLLocationManager()

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
    var routeBuilder: HKWorkoutRouteBuilder?
    var backgroundActivity: CLBackgroundActivitySession?
    var log: Logger = Logger(subsystem: "com.olympsis.watchkit", category: "activity_manager")

    #if os(watchOS)
    var builder: HKLiveWorkoutBuilder?
    #endif

    private var typesToShare: Set = [
        HKObjectType.workoutType(),
        HKSeriesType.workoutRoute(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
    ]

    private var typesToRead: Set = [
        HKSampleType.workoutType(),
        HKSeriesType.workoutRoute(),
        HKSampleType.activitySummaryType(),
        HKSampleType.characteristicType(forIdentifier: .biologicalSex)!,
        HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKQuantityType.quantityType(forIdentifier: .cyclingCadence)!,
    ]

    override init() {
        super.init()
        manager.delegate = self
    }

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

extension WorkoutManager {
    var weekPredicate: NSPredicate {
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now)
        let daysToMonday = (currentWeekday == 1) ? 7 : currentWeekday - 2
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
*/
