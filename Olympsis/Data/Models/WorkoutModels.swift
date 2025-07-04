//
//  WorkoutModels.swift
//  Olympsis
//
//  Created by Joel on 10/16/23.
//

import SwiftUI
import HealthKit
import Foundation
import CoreLocation

@Observable
class Workout: Identifiable {
    
    let id = UUID()
    let type: SUPPORTED_SPORTS
    
    let workout: HKWorkout
    
    var cadence: Double?
    
    var paceSegments: [PaceSegment] = []
    var heartSamples: [HKQuantitySample] = []
    var locationSamples: [CLLocation] = []
    var distanceSamples: [HKQuantitySample] = []
    
    init(type: SUPPORTED_SPORTS, workout: HKWorkout) {
        self.type = type
        self.workout = workout
    }
    
    var name: String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: workout.startDate)
        var timeOfDay: String

        if hour >= 0 && hour < 12 {
            timeOfDay = "Morning"
        } else if hour >= 12 && hour < 17 {
            timeOfDay = "Afternoon"
        } else {
            timeOfDay = "Evening"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // EEEE will give you the full weekday name
        let dayOfWeek = dateFormatter.string(from: workout.startDate)

        return "\(dayOfWeek) \(timeOfDay)"
    }
    
    var totalTime: String {
        let timeInterval = Int(workout.endDate.timeIntervalSince(workout.startDate))
        let minutes = timeInterval / 60
        let seconds = timeInterval % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var averagePace: String {
        guard totalDistance > 0 else {
            return "--:--" // or "N/A" for no distance
        }
        
        let totalMinutes = workout.duration / 60.0
        let paceMinutesPerUnit = totalMinutes / totalDistance // Now correctly calculates pace per unit (km or mile)
        
        let minutes = Int(paceMinutesPerUnit)
        let seconds = Int((paceMinutesPerUnit - Double(minutes)) * 60)
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var averageHeartRate: Double {
        guard !heartSamples.isEmpty else { return 0 }
        
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let heartRateValues = heartSamples.map { $0.quantity.doubleValue(for: heartRateUnit) }
        
        return heartRateValues.reduce(0, +) / Double(heartRateValues.count)
    }
    
    var dateToString: String {
        let today = Date()
        let calendar = Calendar.current
        if calendar.isDate(workout.startDate, equalTo: today, toGranularity: .weekOfYear) {
            if calendar.isDateInYesterday(workout.startDate) {
                return "Yesterday"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE" // EEEE will give you the full weekday name
                return String("\(dateFormatter.string(from: workout.startDate))")
            }
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy" // full date
            return String("\(dateFormatter.string(from: workout.startDate))")
        }
    }
    
    var route2DPoints: [CLLocationCoordinate2D] {
        return locationSamples.map { $0.coordinate }
    }
    
    var totalDistance: Double {
        guard let quantityType = getDistanceQuantityType(for: workout),
              let statistics = workout.allStatistics[quantityType],
              let sum = statistics.sumQuantity() else {
            return 0
        }
        // Return distance in user's preferred unit (miles or kilometers)
        let preferredUnit = Locale.current.measurementSystem == "Metric" ? UnitLength.kilometers : UnitLength.miles
        if preferredUnit == UnitLength.kilometers {
            return sum.doubleValue(for: HKUnit.meter()) / 1000.0 // Convert meters to kilometers
        } else {
            return sum.doubleValue(for: HKUnit.mile())
        }
    }
    
    var totalCaloriesBurned: Double {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let statistics = workout.allStatistics[quantityType],
              let average = statistics.sumQuantity() else {
            return 0
        }
        return average.doubleValue(for: HKUnit.kilocalorie())
    }
}

extension [Workout] {
    func workoutsWithinDateInterval(interval: DateInterval) -> [Workout] {
        return self.filter { $0.workout.startDate >= interval.start && $0.workout.startDate <= interval.end }
    }
    
    func calculateTotalCalories() -> Int {
        return Int(self.reduce(0.0) { $0 + ($1.totalCaloriesBurned) })
    }
       
    func totalCaloriesBurnedPerDay() -> [CaloricDailyAverage] {
       let calendar = Calendar.current
       var caloriesBurnedPerDay = [0, 0, 0, 0, 0, 0, 0]
       var workoutCountPerDay = [0, 0, 0, 0, 0, 0, 0]
           
       for workout in self {
           let startDate = workout.workout.startDate
           let weekday = calendar.component(.weekday, from: startDate)
           
           // Adjust weekday index to be 0 for Monday, 1 for Tuesday, ..., 6 for Sunday
           let index = (weekday + 5) % 7
           caloriesBurnedPerDay[index] += Int(workout.totalCaloriesBurned)
           workoutCountPerDay[index] += 1
       }
       
       var caloricDailyAverages = [CaloricDailyAverage]()
       
       for (index, totalCalories) in caloriesBurnedPerDay.enumerated() {
           _ = workoutCountPerDay[index]
           caloricDailyAverages.append(CaloricDailyAverage(id: index, count: totalCalories))
       }
       
       return caloricDailyAverages
    }

    func totalCaloriesBurnedPerDayInMonth() -> [CaloricDailyAverage] {
       let calendar = Calendar.current
       let now = Date()
       guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
           return []
       }
       let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
       let numDays = range.count
       
       var caloriesBurnedPerDay = [Int]()
       for _ in 0..<numDays {
           caloriesBurnedPerDay.append(0)
       }
       
       for workout in self {
           let startDate = workout.workout.startDate
           let dayOfMonth = calendar.component(.day, from: startDate) - 1 // -1 to convert to 0-based index
           caloriesBurnedPerDay[dayOfMonth] += Int(workout.totalCaloriesBurned)
       }
       
       var caloricDailyAverages = [CaloricDailyAverage]()
       
       for (index, totalCalories) in caloriesBurnedPerDay.enumerated() {
           caloricDailyAverages.append(CaloricDailyAverage(id: index+1, count: totalCalories)) // +1 to convert back to 1-based day
       }
       
       return caloricDailyAverages
    }

    func monthlyAverageCaloriesBurned() -> [CaloricMonthlyAverage] {
       let calendar = Calendar.current
       var caloriesBurnedPerMonth = [Int]()
       var workoutCountPerMonth = [Int]()
       
       for _ in 0..<12 {
           caloriesBurnedPerMonth.append(0)
           workoutCountPerMonth.append(0)
       }
       
       for workout in self {
           let startDate = workout.workout.startDate
           let month = calendar.component(.month, from: startDate) - 1 // -1 to convert to 0-based index
           caloriesBurnedPerMonth[month] += Int(workout.totalCaloriesBurned)
           workoutCountPerMonth[month] += 1
       }
       
       var caloricMonthlyAverages = [CaloricMonthlyAverage]()
       
       for (index, totalCalories) in caloriesBurnedPerMonth.enumerated() {
           _ = workoutCountPerMonth[index]
           caloricMonthlyAverages.append(CaloricMonthlyAverage(id: index, count: totalCalories)) // +1 to convert back to 1-based month
       }
       
       return caloricMonthlyAverages
    }
}

struct CaloricDailyAverage: Identifiable {
    let id: Int
    let count: Int
    
    func dayAbbreviation() -> String {
        switch id {
        case 0: return "Mon"
        case 1: return "Tue"
        case 2: return "Wed"
        case 3: return "Thu"
        case 4: return "Fri"
        case 5: return "Sat"
        case 6: return "Sun"
        default: return ""
        }
    }
}

struct CaloricMonthlyAverage: Identifiable {
    let id: Int
    let count: Int
    
    func monthAbbreviation() -> String {
        switch id {
        case 0: return "Jan"
        case 1: return "Feb"
        case 2: return "Mar"
        case 3: return "Apr"
        case 4: return "May"
        case 5: return "Jun"
        case 6: return "Jul"
        case 7: return "Aug"
        case 8: return "Sept"
        case 9: return "Oct"
        case 10: return "Nov"
        case 11: return "Dec"
        default: return ""
        }
    }
}

struct DistanceSplit: Identifiable {
    let id: Int
    let pace: Double
    let distance: Double // In meters
    let elevation: Int
    
    func formatDistance(unit: UnitLength) -> Double {
        switch unit {
        case .miles:
            return distance / 1609.344
        default:
            return distance
        }
    }
}


enum WorkoutError: Error {
    case failedQuery
}

struct WorkoutQueryConfig {
    let pageSize: Int
    let sports: [SUPPORTED_SPORTS]
    let dateRange: DateInterval?
    let cursor: Date? // For pagination
    
    static let `default` = WorkoutQueryConfig(
        pageSize: 20,
        sports: SUPPORTED_SPORTS.allCases,
        dateRange: nil,
        cursor: nil
    )
}

struct WorkoutDetails {
    let route: [CLLocation]
    let cadence: Double
    let paceSegments: [PaceSegment]
    let heartRateSamples: [HKQuantitySample]
    let splits: [PaceSegment]
}

// MARK: - Pace Analysis Models
struct PaceSegment: Identifiable {
    let id = UUID()
    let segmentNumber: Int
    let distance: Double // Distance in meters
    let duration: TimeInterval // Duration in seconds
    let elevationGain: Double // Elevation gain in meters
    let elevationLoss: Double // Elevation loss in meters
    let startTime: Date
    let endTime: Date
    let detailSamples: [PaceDetailSample] // Sub-segments for detailed analysis
    
    init(segmentNumber: Int, distance: Double, duration: TimeInterval,
         elevationGain: Double, elevationLoss: Double, startTime: Date, endTime: Date,
         detailSamples: [PaceDetailSample] = []) {
        self.segmentNumber = segmentNumber
        self.distance = distance
        self.duration = duration
        self.elevationGain = elevationGain
        self.elevationLoss = elevationLoss
        self.startTime = startTime
        self.endTime = endTime
        self.detailSamples = detailSamples
    }
    
    func getPace(for unit: UnitLength) -> Double {
        let conversionFactor: Double = unit == .kilometers ? 1000.0 : 1609.344
        let distanceInUnit = distance / conversionFactor
        return duration / distanceInUnit // Returns seconds per unit
    }
}

struct PaceDetailSample: Identifiable {
    let id = UUID()
    let distance: Double // Distance in meters (0.1km or 0.1 mile)
    let duration: TimeInterval // Duration in seconds
    let pace: Double // Pace in seconds per unit
    let startTime: Date
    let endTime: Date
    
    init(distance: Double, duration: TimeInterval, pace: Double, startTime: Date, endTime: Date) {
        self.distance = distance
        self.duration = duration
        self.pace = pace
        self.startTime = startTime
        self.endTime = endTime
    }
}

enum ActivitiesSummaryType {
    case distance
    case calories
    case time
}


// MARK: - RouteSegment Data Structure
struct RouteSegment {
    let segmentNumber: Int
    let distance: Double // Distance from start (cumulative)
    let segmentDistance: Double // Distance of this segment (0.1 mile/km)
    let duration: TimeInterval // Time from start (cumulative)
    let segmentDuration: TimeInterval // Duration of this segment
    let pace: Double // Pace for this segment (min/mile or min/km)
    let elevation: Double // Elevation at this point (meters)
    let heartRate: Double // Heart rate at this point (BPM)
    let location: CLLocation // Location at this point
    let startTime: Date
    let endTime: Date
}

struct DetailedWorkoutData {
    let routeSegments: [RouteSegment]
    let totalDistance: Double
    let totalDuration: TimeInterval
    let averagePace: Double
    let elevationGain: Double
    let elevationLoss: Double
    let averageHeartRate: Double
    let maxHeartRate: Double
    let minHeartRate: Double
}

// MARK: - Raw Sample Data
struct WorkoutRawData {
    let locations: [CLLocation]
    let heartRateSamples: [HKQuantitySample]
    let distanceSamples: [HKQuantitySample]
    let startDate: Date
    let endDate: Date
}
