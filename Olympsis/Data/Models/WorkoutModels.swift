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

class Workout: Identifiable {
    
    let id = UUID()
    let type: SPORTS
    
    let workout: HKWorkout
    
    var caloriesBurned: Double = 100
    
    var heartSamples: [HKQuantitySample] = []
    var locationSamples: [HKWorkoutRoute] = []
    var distanceSamples: [HKQuantitySample] = []
    
    init(type: SPORTS, workout: HKWorkout) {
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

        return "\(dayOfWeek) \(timeOfDay) \(sportInString(workout: self))"
    }
    
    var totalTime: String {
        let timeInterval = Int(workout.endDate.timeIntervalSince(workout.startDate))
        let minutes = timeInterval / 60
        let seconds = timeInterval % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var averagePace: String {
        let distanceTraveled = distanceSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.mile()) }
        let timeInterval = workout.endDate.timeIntervalSince(workout.startDate)
        let totalMinutes = timeInterval / 60.0
        let averagePace = (totalMinutes/(distanceTraveled)) == .infinity ? 0 : totalMinutes/(distanceTraveled)
        
        let minutes = Int(averagePace)
        let seconds = Int((averagePace - Double(minutes)) * 60)
        
        return String(format: "%02d:%02d", minutes, seconds)
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
    
    var totalDistance: Double {
        return distanceSamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.mile()) }
    }
    
    var averageHeartRate: Double {
        let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        guard let bpm = heartSamples.last?.quantity.doubleValue(for: unit) else {
            return 0
        }
        return bpm
    }
}

extension [Workout] {
    func calculateTotalCalories() -> Int {
        return Int(self.reduce(0.0) { $0 + ($1.caloriesBurned) })
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
           caloriesBurnedPerDay[index] += Int(workout.caloriesBurned)
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
           caloriesBurnedPerDay[dayOfMonth] += Int(workout.caloriesBurned)
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
           caloriesBurnedPerMonth[month] += Int(workout.caloriesBurned)
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
