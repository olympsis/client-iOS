//
//  WorkoutSession.swift
//  OlympsisCompanion Watch App
//
//  Created by Joel on 10/15/23.
//

import SwiftUI
import HealthKit
import WorkoutKit
import Foundation

@MainActor
@Observable
final class WorkoutSession {
    
    var selectedSport = 0
    var session: HKWorkoutSession?
    var builder: HKWorkoutBuilder?
    let healthStore = HKHealthStore()
    let configuration = HKWorkoutConfiguration()
    
    private var typesToShare: Set = [
        HKQuantityType.workoutType()
    ]
    
    private var typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    ]
    
    func requestHealthStoreAuthorization() async {
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            print(error)
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
    
    func startWorkoutSession() {
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            print(error)
        }
    }
}
