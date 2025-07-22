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
import CoreLocation

@Observable
class WorkoutManager: NSObject {
    
    var workouts = [Workout]()
    var samples: [HKSample] = []
    var events: [HKWorkoutEvent] = []
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
    
    var selectedSport: SUPPORTED_SPORTS? {
        didSet {
            Task {
                await MainActor.run {
                    guard let sport = selectedSport else { return }
                    selectedWorkout = sport.getWorkoutActivityType()
                }
            }
        }
    }
    
    var selectedWorkout: HKWorkoutActivityType?
    var workout: HKWorkout?
    
    var state: WORKOUT_STATES = .pending
    var viewState: LOADING_STATE = .pending
    
    var showingSummaryView: Bool = false {
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
        HKQuantityType.quantityType(forIdentifier: .height)!,
        HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
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
    func requestHealthStoreAuthorization() async -> Bool{
        do {
            guard HKHealthStore.isHealthDataAvailable() else {
                log.error("HealthKit is not available on this device")
                return false
            }
            
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            return true
        } catch {
            log.error("Failed to request health store authorization \(error.localizedDescription, privacy: .public)")
            return false
        }
    }
    
    @MainActor
    func requestLocationAccess() {
        manager.requestWhenInUseAuthorization()
    }
    
    @MainActor
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let _ = statistics.maximumQuantity()
            self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            self.zone = self.getZoneFromHeartRate(self.heartRate)
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
    
    @MainActor
    func enableWaterEjectMode() {
        #if os(watchOS)
        guard WKInterfaceDevice.current().isWaterLockEnabled else { return }
        WKInterfaceDevice.current().enableWaterLock()
        #endif
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
