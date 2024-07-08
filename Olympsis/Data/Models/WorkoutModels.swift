//
//  WorkoutModels.swift
//  Olympsis
//
//  Created by Joel on 10/16/23.
//

import SwiftUI
import Foundation

enum WorkoutType {
    case walking
    case running
    case soccer
}

struct Workout: Identifiable {
    let id: UUID
    let type: WorkoutType
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
        let averagePace = totalMinutes / totalDistanceTraveled
        
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
