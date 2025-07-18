//
//  WorkoutManager+Workout.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/11/25.
//

import HealthKit
import Foundation

#if os(watchOS)
extension WorkoutManager: @preconcurrency HKLiveWorkoutBuilderDelegate {
    
}
#endif

extension WorkoutManager {

    func buildWorkout(_ workout: HKWorkoutActivityType, location: HKWorkoutSessionLocationType) {
        let configuration: HKWorkoutConfiguration = {
            let config = HKWorkoutConfiguration()
            config.activityType = workout
            config.locationType = location
            return config
        }()
        
        if location == .outdoor {
            self.routeBuilder = HKWorkoutRouteBuilder(healthStore: self.healthStore, device: .local())
        }
        
        do {
            #if os(watchOS)
            session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            builder = session?.associatedWorkoutBuilder()
            #endif
        } catch {
            self.log.error("Failed to start workout session: \(error.localizedDescription, privacy: .public)")
            return
        }
        
        #if os(watchOS)
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        #endif
        
        session?.delegate = self
        
        #if os(watchOS)
        builder?.delegate = self
        #endif
    }
    
    /// Prepares a workout and resets and cleans up session data
    func prepareWorkout() {
        session?.prepare()
    }
    
    /// Starts a workout
    func startWorkout() async {
        let startDate = Date()
        
        self.zones = await self.generateHeartRateZones()
        
        do {
            session?.startActivity(with: startDate)
            #if os(watchOS)
            try await builder?.beginCollection(at: startDate)
            #endif
        } catch {
            self.log.error("Failed to start collecting data from workout: \(error.localizedDescription, privacy: .public)")
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
        #if os(watchOS)
        if Double(builder?.elapsedTime ?? 0) < 60 {
            guard session != nil else {
                return
            }
            session?.stopActivity(with: session?.currentActivity.startDate)
            resetWorkout()
            state = .ended
            self.stopListeningToLocationUpdates()
            log.info("Workout ended early")
        }
        #endif
        session?.end()
    }
    
    /// Resets all of the data around workouts
    func resetWorkout() {
        if let workout,
           let selectedSport  {
            let work = Workout(type: selectedSport, workout: workout)
            workouts.append(work)
        }
        
        #if os(watchOS)
        builder = nil
        #endif
        
        selectedSport = nil
        selectedWorkout = nil
        routeBuilder = nil
        session = nil
        workout = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
    }
}
