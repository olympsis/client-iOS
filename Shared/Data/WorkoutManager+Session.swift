//
//  WorkoutManager+Session.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/3/24.
//

import os
import SwiftUI
// import HealthKit
import CoreLocation

/*
extension WorkoutManager: HKWorkoutSessionDelegate {

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
//                    listenToLocationUpdates()
                    manager.startUpdatingLocation()
                    self.log.info("Workout state changed -> ACTIVE")
                }
            }
        case .ended:
            Task { @MainActor in
                do {
                    self.isProcessingWorkout = true

                    #if os(watchOS)
                    try await builder?.endCollection(at: date)
                    let workout = try await self.builder?.finishWorkout()
                    #endif

                    self.workout = workout
                    self.state = .ended
                    self.isProcessingWorkout = false
                    self.showingSummaryView = true

                    self.log.info("Workout state changed -> ENDED")

                    guard let routeBuilder,
                          let workout else {
                        return
                    }

//                    stopListeningToLocationUpdates()
                    manager.stopUpdatingLocation()

                    try await routeBuilder.finishRoute(with: workout, metadata: [:])
                    log.info("Workout Route finished.")
                } catch {
                    self.state = .ended
                    self.log.error("Failed to finish workout: \(error.localizedDescription, privacy: .public)")
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
*/
