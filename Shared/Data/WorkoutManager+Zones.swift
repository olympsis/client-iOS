//
//  WorkoutManager+Zones.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/11/25.
//

import HealthKit
import Foundation

extension WorkoutManager {
    
    /// Determines which heart rate zone a given heart rate falls into
    /// - Parameter heartRate: Heart rate in beats per minute
    /// - Returns: Zone number (1-5), or 0 if outside all zones or zones not available
    func getZoneFromHeartRate(_ heartRate: Double) -> Int {
        guard !zones.isEmpty else {
            log.error("No heart rate zones available for zone calculation")
            return 2
        }
        
        let heartRateInt = Int(heartRate.rounded())
        
        for (index, zone) in zones.enumerated() {
            if heartRateInt >= zone.minHeartRate && heartRateInt <= zone.maxHeartRate {
                return index + 1 // Return 1-based zone number
            }
        }
        
        log.warning("Heart rate \(heartRateInt) bpm does not fall within any defined zone")
        return 1
    }
    
    func generateHeartRateZones() async -> [HeartRateZone] {
        // Request HealthKit permissions
        guard await requestHealthStoreAuthorization() else {
            log.error("HealthKit permissions not granted")
            return generateFallbackZones()
        }
        
        // Get user's age
        guard let age = await getUserAge() else {
            log.error("Unable to retrieve user age from HealthKit")
            return generateFallbackZones()
        }
        
        // Get resting heart rate (30-day average)
        guard let restingHeartRate = await getRestingHeartRate() else {
            log.error("Unable to retrieve resting heart rate from HealthKit")
            return generateFallbackZones()
        }
        
        // Calculate maximum heart rate (220 - age)
        let maxHeartRate = 220 - age
        
        log.info("Calculating zones: Age=\(age), RestingHR=\(restingHeartRate), MaxHR=\(maxHeartRate)")
        
        // Generate zones using Karvonen formula
        let zones = zoneDefinitions.map { zone in
            let minHR = calculateKarvonenHeartRate(
                maxHR: maxHeartRate,
                restingHR: restingHeartRate,
                intensity: zone.minPercent
            )
            let maxHR = calculateKarvonenHeartRate(
                maxHR: maxHeartRate,
                restingHR: restingHeartRate,
                intensity: zone.maxPercent
            )
            
            return HeartRateZone(
                name: zone.name,
                minHeartRate: minHR,
                maxHeartRate: maxHR,
                intensityRange: "\(Int(zone.minPercent * 100))-\(Int(zone.maxPercent * 100))%"
            )
        }
        
        log.info("Successfully generated \(zones.count) heart rate zones")
        return zones
    }
    
    private func generateFallbackZones() -> [HeartRateZone] {
        log.warning("Using generalized heart rate zones (no age data available)")
        
        // These are typical zones for moderate fitness adults
        return [
            HeartRateZone(
                name: "Zone 1: Light",
                minHeartRate: 90,
                maxHeartRate: 120,
                intensityRange: "50-60%"
            ),
            HeartRateZone(
                name: "Zone 2: Moderate",
                minHeartRate: 120,
                maxHeartRate: 140,
                intensityRange: "60-70%"
            ),
            HeartRateZone(
                name: "Zone 3: Hard",
                minHeartRate: 140,
                maxHeartRate: 160,
                intensityRange: "70-80%"
            ),
            HeartRateZone(
                name: "Zone 4: Maximum",
                minHeartRate: 160,
                maxHeartRate: 180,
                intensityRange: "80-90%"
            ),
            HeartRateZone(
                name: "Zone 5: All Out",
                minHeartRate: 180,
                maxHeartRate: 200,
                intensityRange: "90-100%"
            )
        ]
    }
    
    private func getUserAge() async -> Int? {
        do {
            let dateOfBirthComponents = try healthStore.dateOfBirthComponents()
            let calendar = Calendar.current
            
            // Convert DateComponents to Date
            guard let dateOfBirth = calendar.date(from: dateOfBirthComponents) else {
                log.error("Unable to create date from birth components")
                return nil
            }
            
            let now = Date()
            let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
            return ageComponents.year
        } catch {
            log.error("Failed to get user age: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getRestingHeartRate() async -> Int? {
        guard let restingHRType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            log.error("Unable to create resting heart rate quantity type")
            return nil
        }
        
        // Create predicate for last 30 days
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: restingHRType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in
                if let error = error {
                    self.log.error("Resting heart rate query failed: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let statistics = statistics,
                      let averageHeartRate = statistics.averageQuantity() else {
                    self.log.error("No resting heart rate data found")
                    continuation.resume(returning: nil)
                    return
                }
                
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRateValue = Int(averageHeartRate.doubleValue(for: heartRateUnit))
                
                self.log.info("Retrieved 30-day average resting heart rate: \(heartRateValue) bpm")
                continuation.resume(returning: heartRateValue)
            }
            
            self.healthStore.execute(query)
        }
    }
    
    /// Calculates target heart rate using Karvonen formula
    /// Formula: Target HR = ((Max HR - Resting HR) × Intensity%) + Resting HR
    private func calculateKarvonenHeartRate(maxHR: Int, restingHR: Int, intensity: Double) -> Int {
        let targetHR = Double(maxHR - restingHR) * intensity + Double(restingHR)
        return Int(targetHR.rounded())
    }
}
