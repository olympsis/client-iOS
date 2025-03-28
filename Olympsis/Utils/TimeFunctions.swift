//
//  TimeFunctions.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/23.
//

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
            return "\(seconds)s"
        } else {
            if seconds == 1 {
                return "\(seconds) second ago"
            } else {
                return "\(seconds) seconds ago"
            }
        }
    } else if timeDifference < secondsInAnHour {
        let minutes = Int(timeDifference / secondsInAMinute)
        if shortned {
            return "\(minutes)m"
        } else {
            if minutes == 1 {
                return "\(minutes) minute ago"
            } else {
                return "\(minutes) minutes ago"
            }
        }
    } else if timeDifference < secondsInADay {
        let hours = Int(timeDifference / secondsInAnHour)
        if shortned {
            return "\(hours)h"
        } else {
            if hours == 1 {
                return "\(hours) hour ago"
            } else {
                return "\(hours) hours ago"
            }
        }
    } else if timeDifference < secondsInAMonth {
        let days = Int(timeDifference / secondsInADay)
        if shortned {
            return "\(days)d"
        } else {
            if days == 1 {
                return "\(days) day ago"
            } else {
                return "\(days) days ago"
            }
        }
    } else if timeDifference < secondsInAYear {
        let months = Int(timeDifference / secondsInAMonth)
        if shortned {
            return "\(months)m"
        } else {
            if months == 1 {
                return "\(months) month ago"
            } else {
                return "\(months) months ago"
            }
        }
    } else {
        let years = Int(timeDifference / secondsInAYear)
        if shortned {
            return "\(years)y"
        } else {
            if years == 1 {
                return "\(years) year ago"
            } else {
                return "\(years) years ago"
            }
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
