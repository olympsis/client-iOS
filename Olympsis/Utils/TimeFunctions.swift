//
//  TimeFunctions.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/23.
//

import HealthKit
import Foundation

func calculateTimeAgo(from date: Date, shortned: Bool = false) -> String {
    let currentTime = Date()
    let timeDifference = currentTime.timeIntervalSince(date)
    
    let secondsInAMinute: Double = 60
    let secondsInAnHour: Double = 3600
    let secondsInADay: Double = 86400
    let secondsInAMonth: Double = 2629800
    let secondsInAYear: Double = 31557600
    
    if timeDifference < secondsInAMinute {
        let seconds = Int(timeDifference)
        if shortned {
            return String(localized: "\(seconds) second-shortened", table: "Time")
        } else {
            return String(localized: "\(seconds) sec-ago", table: "Time")
        }
    } else if timeDifference < secondsInAnHour {
        let minutes = Int(timeDifference / secondsInAMinute)
        if shortned {
            return String(localized: "\(minutes) minute-shortened", table: "Time")
        } else {
            return String(localized: "\(minutes) min-ago", table: "Time")
        }
    } else if timeDifference < secondsInADay {
        let hours = Int(timeDifference / secondsInAnHour)
        if shortned {
            return String(localized: "\(hours) hour-shortened", table: "Time")
        } else {
            return String(localized: "\(hours) hr-ago", table: "Time")
        }
    } else if timeDifference < secondsInAMonth {
        let days = Int(timeDifference / secondsInADay)
        if shortned {
            return String(localized: "\(days) day-shortened", table: "Time")
        } else {
            return String(localized: "\(days) day-ago", table: "Time")
        }
    } else if timeDifference < secondsInAYear {
        let months = Int(timeDifference / secondsInAMonth)
        if shortned {
            return String(localized: "\(months) month-shortened", table: "Time")
        } else {
            return String(localized: "\(months) mo-ago", table: "Time")
        }
    } else {
        let years = Int(timeDifference / secondsInAYear)
        if shortned {
            return String(localized: "\(years) year-shortened", table: "Time")
        } else {
            return String(localized: "\(years) yr-ago", table: "Time")
        }
    }
}

// No changes needed for this function as it already uses Date
func areDatesOnSameDay(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
    let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
    
    return components1.year == components2.year &&
           components1.month == components2.month &&
           components1.day == components2.day
}

func formatAbbreviatedTimestamp(_ date: Date?) -> String {
    // Safely unwrap the optional date
    guard let date = date else {
        return "Contact Me"
    }
    
    let formatter = DateFormatter()
    
    // Set the month abbreviation
    formatter.dateFormat = "MMM"
    let month = formatter.string(from: date)
    
    // Set the day and year format
    formatter.dateFormat = "d"
    let day = formatter.string(from: date)
    
    formatter.dateFormat = "yyyy"
    let year = formatter.string(from: date)
    
    // Format the last two digits of the year
    let yearFormatted = String(year.suffix(2))
    
    // Set the time format to hh:mm
    formatter.dateFormat = "HH:mm a"
    let time = formatter.string(from: date)
    
    return "\(month).\(day).\(yearFormatted) - \(time)"
}

func formatDateFromTimestamp(_ date: Date?) -> String {
    // Safely unwrap the optional date
    guard let date = date else {
        return "Contact Me"
    }
    
    let formatter = DateFormatter()
    
    // Set the month abbreviation
    formatter.dateFormat = "MMM"
    let month = formatter.string(from: date)
    
    // Set the day and year format
    formatter.dateFormat = "d"
    let day = formatter.string(from: date)
    
    formatter.dateFormat = "yyyy"
    let year = formatter.string(from: date)
    
    // Format the last two digits of the year
    let yearFormatted = String(year.suffix(2))
    
    return "\(month) \n\(day) \n\(yearFormatted)"
}

func formatTimeFromTimestamp(_ date: Date?) -> String {
    // Safely unwrap the optional date
    guard let date = date else {
        return "Contact Me"
    }
    
    let formatter = DateFormatter()
    
    formatter.dateFormat = "HH"
    let hour = formatter.string(from: date)
    
    formatter.dateFormat = "mm"
    let minutes = formatter.string(from: date)
    
    formatter.dateFormat = "a"
    let am = formatter.string(from: date)
    
    return "\(hour) \n\(minutes) \n\(am)"
}

func parseDate(from dateString: String) throws -> Date {
    // Create a standard ISO8601 formatter
    let iso8601Formatter = ISO8601DateFormatter()
    
    // Try the ISO8601 formatter first
    if let date = iso8601Formatter.date(from: dateString) {
        return date
    }
    
    // Create a more flexible DateFormatter
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    // Array of date formats to try
    let dateFormats = [
        "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        "yyyy-MM-dd'T'HH:mm:ss",
        "yyyy-MM-dd"
    ]
    
    // Try each format
    for format in dateFormats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
    }
    

    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unable to parse date string: \(dateString)"))
}

func getWorkoutStartDateTime(from workout: HKWorkout) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M/dd/yy - h:mm a"
    return dateFormatter.string(from: workout.startDate)
}
