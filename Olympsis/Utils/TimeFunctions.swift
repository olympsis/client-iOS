//
//  TimeFunctions.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/23.
//

import Foundation

func calculateTimeAgo(from timestamp: Int64) -> String {
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
