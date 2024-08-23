//
//  TimeFunctions.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/23.
//

import Foundation

func calculateTimeAgo(from timestamp: Int) -> String {
    let currentTime = Date().timeIntervalSince1970
    let timeDifference = currentTime - Double(timestamp)
    
    let secondsInAMinute: Double = 60
    let secondsInAnHour: Double = 3600
    let secondsInADay: Double = 86400
    let secondsInAMonth: Double = 2629800
    let secondsInAYear: Double = 31557600
    
    if timeDifference < secondsInAMinute {
        let seconds = Int(timeDifference)
        if seconds == 1 {
            return "\(seconds) second ago"
        } else {
            return "\(seconds) seconds ago"
        }
    } else if timeDifference < secondsInAnHour {
        let minutes = Int(timeDifference / secondsInAMinute)
        if minutes == 1 {
            return "\(minutes) minute ago"
        } else {
            return "\(minutes) minutes ago"
        }
    } else if timeDifference < secondsInADay {
        let hours = Int(timeDifference / secondsInAnHour)
        if hours == 1 {
            return "\(hours) hour ago"
        } else {
            return "\(hours) hours ago"
        }
    } else if timeDifference < secondsInAMonth {
        let days = Int(timeDifference / secondsInADay)
        if days == 1 {
            return "\(days) day ago"
        } else {
            return "\(days) days ago"
        }
    } else if timeDifference < secondsInAYear {
        let months = Int(timeDifference / secondsInAMonth)
        if months == 1 {
            return "\(months) month ago"
        } else {
            return "\(months) months ago"
        }
    } else {
        let years = Int(timeDifference / secondsInAYear)
        if years == 1 {
            return "\(years) year ago"
        } else {
            return "\(years) years ago"
        }
    }
}


func areDatesOnSameDay(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
    let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
    
    return components1.year == components2.year &&
           components1.month == components2.month &&
           components1.day == components2.day
}

func formatAbbreviatedTimestamp(_ timestamp: Int?) -> String {
    // Safely unwrap the optional timestamp
    guard let timestamp = timestamp else {
        return "Contact Me"
    }
    
    // Convert the integer timestamp to a Date object
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
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
    
    // Set the MM.DD.YY format
//    formatter.dateFormat = "MM.dd.yy"
//    let mmddyy = formatter.string(from: date)
    
    // Set the time format to hh:mm
    formatter.dateFormat = "HH:mm a"
    let time = formatter.string(from: date)
    
    return "\(month).\(day).\(yearFormatted) - \(time)"
}

func formatDateFromTimestamp(_ timestamp: Int?) -> String {
    // Safely unwrap the optional timestamp
    guard let timestamp = timestamp else {
        return "Contact Me"
    }
    
    // Convert the integer timestamp to a Date object
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
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
    
    // Set the MM.DD.YY format
//    formatter.dateFormat = "MM.dd.yy"
//    let mmddyy = formatter.string(from: date)
    
    // Set the time format to hh:mm
//    formatter.dateFormat = "HH:mm a"
//    let time = formatter.string(from: date)
    
    return "\(month) \n\(day) \n\(yearFormatted)"
}

func formatTimeFromTimestamp(_ timestamp: Int?) -> String {
    // Safely unwrap the optional timestamp
    guard let timestamp = timestamp else {
        return "Contact Me"
    }
    
    // Convert the integer timestamp to a Date object
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let formatter = DateFormatter()
    
    // Set the time format to hh:mm
//    formatter.dateFormat = "HH:mm a"
//    let time = formatter.string(from: date)
    
    formatter.dateFormat = "HH"
    let hour = formatter.string(from: date)
    
    formatter.dateFormat = "mm"
    let minutes = formatter.string(from: date)
    
    formatter.dateFormat = "a"
    let am = formatter.string(from: date)
    
    return "\(hour) \n\(minutes) \n\(am)"
}
