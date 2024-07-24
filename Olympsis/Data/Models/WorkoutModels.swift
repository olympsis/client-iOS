//
//  WorkoutModels.swift
//  Olympsis
//
//  Created by Joel on 10/16/23.
//

import SwiftUI
import Foundation

struct Workout: Identifiable {
    let id: UUID
    let type: SPORTS
    let startDate: Date
    let endDate: Date
    let averageHeartRate: Double
    let caloriesBurned: Double
    let totalDistanceTraveled: Double
    let cadence: Double?=nil
    let vo2Max: Double?=nil
    
    /// Computed property of time ellapsed in this event
    var ellapsedTime: String {
        let timeInterval = Int(endDate.timeIntervalSince(startDate))
        let minutes = timeInterval / 60
        let seconds = timeInterval % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var averagePace: String {
        
        let timeInterval = endDate.timeIntervalSince(startDate)
        let totalMinutes = timeInterval / 60.0
        let averagePace = (totalMinutes/totalDistanceTraveled) == .infinity ? 0 : totalMinutes/totalDistanceTraveled
        
        let minutes = Int(averagePace)
        let seconds = Int((averagePace - Double(minutes)) * 60)
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Computed property of workout date to return either day of the week or date
    var dateToString: String {
        let today = Date()
        let calendar = Calendar.current
        
        // Check if the date is within the same week as today
        if calendar.isDate(startDate, equalTo: today, toGranularity: .weekOfYear) {
            if calendar.isDateInYesterday(startDate) {
                return "Yesterday"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE" // EEEE will give you the full weekday name
                return String("\(dateFormatter.string(from: startDate))")
            }
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy" // full date
            return String("\(dateFormatter.string(from: startDate))")
        }
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

extension [Workout] {
    func calculateTotalCalories() -> Int {
        return Int(self.reduce(0.0) { $0 + $1.caloriesBurned })
    }
       
   func totalCaloriesBurnedPerDay() -> [CaloricDailyAverage] {
       let calendar = Calendar.current
       var caloriesBurnedPerDay = [0, 0, 0, 0, 0, 0, 0]
       var workoutCountPerDay = [0, 0, 0, 0, 0, 0, 0]
           
       for workout in self {
           let startDate = workout.startDate
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
           let startDate = workout.startDate
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
           let startDate = workout.startDate
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
