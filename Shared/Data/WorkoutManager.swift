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

// MARK: - Stub for HKLiveWorkoutBuilder (HealthKit disabled)
/// Minimal stub so watchOS views referencing `manager.builder?.elapsedTime` etc. still compile.
class WorkoutBuilderStub {
    var elapsedTime: TimeInterval = 0
    var startDate: Date? = nil
}

// MARK: - WorkoutManager stub (HealthKit disabled)
@Observable
class WorkoutManager: NSObject {

    var workouts = [Workout]()
    var manager = CLLocationManager()

    var sportFilter: SUPPORTED_SPORTS?
    var frequencyFilter: Int = 0

    var fetchingCursor: Date? = nil
    var locationTask: Task<Void, Never>? = nil
    var backgroundTask: Task<Void, Never>? = nil

    var hasLocationAccess: Bool {
        switch (manager.authorizationStatus) {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined, .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    var selectedSport: SUPPORTED_SPORTS?

    var state: WORKOUT_STATES = .pending
    var viewState: LOADING_STATE = .pending

    var showingSummaryView: Bool = false
    var isProcessingWorkout: Bool = false

    // Live Workout Statistics
    var locationPoints: [CLLocation] = []
    var averageHeartRate: Double = 0
    var heartRate: Double = 0
    var activeEnergy: Double = 0
    var distance: Double = 0
    var zone: Int = 1

    var zones: [HeartRateZone] = []

    let zoneDefinitions: [(name: String, minPercent: Double, maxPercent: Double)] = [
        ("Zone 1 - Active Recovery", 0.50, 0.60),
        ("Zone 2 - Aerobic Base", 0.60, 0.70),
        ("Zone 3 - Aerobic", 0.70, 0.80),
        ("Zone 4 - Lactate Threshold", 0.80, 0.90),
        ("Zone 5 - VO2 Max", 0.90, 1.00)
    ]

    var unit: UnitLength = Locale.current.measurementSystem == "Metric" ? UnitLength.kilometers : UnitLength.miles

    var backgroundActivity: CLBackgroundActivitySession?
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "activity_manager")

    // Stubs for properties that previously used HealthKit types
    var session: AnyObject? = nil
    var builder: WorkoutBuilderStub? = nil
    var workout: WorkoutData? = nil

    override init() {
        super.init()
        manager.delegate = self
    }

    @MainActor
    func requestLocationAccess() {
        manager.requestWhenInUseAuthorization()
    }

    /// Stub - HealthKit disabled, returns nil
    func fetchWorkoutAdditionalData(from workout: WorkoutData) async -> WorkoutDetails? {
        return nil
    }

    /// Stub - HealthKit disabled, returns fallback zones
    func generateHeartRateZones() async -> [HeartRateZone] {
        return [
            HeartRateZone(name: "Zone 1: Light", minHeartRate: 90, maxHeartRate: 120, intensityRange: "50-60%"),
            HeartRateZone(name: "Zone 2: Moderate", minHeartRate: 120, maxHeartRate: 140, intensityRange: "60-70%"),
            HeartRateZone(name: "Zone 3: Hard", minHeartRate: 140, maxHeartRate: 160, intensityRange: "70-80%"),
            HeartRateZone(name: "Zone 4: Maximum", minHeartRate: 160, maxHeartRate: 180, intensityRange: "80-90%"),
            HeartRateZone(name: "Zone 5: All Out", minHeartRate: 180, maxHeartRate: 200, intensityRange: "90-100%"),
        ]
    }

    /// Stub - HealthKit disabled
    func getZoneFromHeartRate(_ heartRate: Double) -> Int {
        guard !zones.isEmpty else { return 2 }
        let heartRateInt = Int(heartRate.rounded())
        for (index, zone) in zones.enumerated() {
            if heartRateInt >= zone.minHeartRate && heartRateInt <= zone.maxHeartRate {
                return index + 1
            }
        }
        return 1
    }

    // MARK: - Workout control stubs (HealthKit disabled)

    func prepareWorkout() {
        log.info("HealthKit disabled - prepareWorkout is a no-op")
    }

    func startWorkout() async {
        log.info("HealthKit disabled - startWorkout is a no-op")
    }

    func pauseWorkout() {
        log.info("HealthKit disabled - pauseWorkout is a no-op")
        state = .paused
    }

    func resumeWorkout() {
        log.info("HealthKit disabled - resumeWorkout is a no-op")
        state = .active
    }

    func stopWorkout() {
        log.info("HealthKit disabled - stopWorkout is a no-op")
        state = .ended
    }

    func resetWorkout() {
        state = .pending
        distance = 0
        activeEnergy = 0
        heartRate = 0
        averageHeartRate = 0
        locationPoints = []
        workout = nil
        builder = nil
        session = nil
    }

    func buildWorkout(_ activityType: Any, location: Any) {
        log.info("HealthKit disabled - buildWorkout is a no-op")
    }

    @MainActor
    func enableWaterEjectMode() {
        #if os(watchOS)
        guard WKInterfaceDevice.current().isWaterLockEnabled else { return }
        WKInterfaceDevice.current().enableWaterLock()
        #endif
    }

    /// Stub - HealthKit disabled
    func fetchWorkoutsHistory(in predicate: String?) async {
        log.info("HealthKit disabled - fetchWorkoutsHistory is a no-op")
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
