//
//  Global Variables.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import UIKit
import SwiftUI
import Foundation

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

func milesToMeters(radius: Double) -> Double {
    return (radius*DISTANCE_CONVERTIONS.MILES_TO_METERS.rawValue)
}

func metersToMiles(radius: Double) -> Double {
    return (radius/DISTANCE_CONVERTIONS.MILES_TO_METERS.rawValue)
}

enum DISTANCE_CONVERTIONS: Double {
    case MILES_TO_METERS = 1609.34
    case MILES_TO_KILOMETERS = 1.60934
}

struct CornerRadiusShape: Shape {
    var radius = CGFloat.infinity
    var corners = UIRectCorner.allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

let defaultClubImageURLS = [
    "club-images/ab9cc0d0-320b-4320-917c-691768c71416.png",
    "club-images/f7f28720-cfd3-4cfd-94b6-e54bc97f7089.png",
    "club-images/b86df4d8-7e30-47e3-a7fd-ba7fa4296105.png"
]

func parseLocationData(_ locationString: String) -> String {
    let lines = locationString.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var locationStrings: [String] = []
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    for (index, line) in lines.enumerated() {
        print("Processing line \(index + 1): \(line)")
        
        // Parse key=value pairs
        var locationData: [String: String] = [:]
        let pairs = line.components(separatedBy: ", ")
        
        for pair in pairs {
            let keyValue = pair.components(separatedBy: "=")
            if keyValue.count == 2 {
                locationData[keyValue[0].trimmingCharacters(in: .whitespaces)] = keyValue[1].trimmingCharacters(in: .whitespaces)
            }
        }
        
        print("Parsed data: \(locationData)")
        
        // Extract and validate each value
        guard let latString = locationData["lat"],
              let longString = locationData["long"],
              let altitudeString = locationData["altitude"],
              let hAccuracyString = locationData["horizontalAccuracy"],
              let vAccuracyString = locationData["verticalAccuracy"],
              let courseString = locationData["course"],
              let courseAccuracyString = locationData["courseAccuracy"],
              let speedString = locationData["speed"],
              let speedAccuracyString = locationData["speedAccuracy"],
              let timestampString = locationData["timestamp"] else {
            print("Missing required fields in line \(index + 1)")
            continue
        }
        
        guard let lat = Double(latString),
              let long = Double(longString),
              let altitude = Double(altitudeString),
              let hAccuracy = Double(hAccuracyString),
              let vAccuracy = Double(vAccuracyString),
              let course = Double(courseString),
              let courseAccuracy = Double(courseAccuracyString),
              let speed = Double(speedString),
              let speedAccuracy = Double(speedAccuracyString) else {
            print("Failed to convert numeric values in line \(index + 1)")
            continue
        }
        
        guard let timestamp = dateFormatter.date(from: timestampString) else {
            print("Failed to parse timestamp '\(timestampString)' in line \(index + 1)")
            continue
        }
        
        // Convert timestamp to time interval since reference date (Jan 1, 2001)
        let timeInterval = timestamp.timeIntervalSinceReferenceDate
        
        // Format CLLocation string
        let locationString = """
CLLocation(coordinate: CLLocationCoordinate2D(latitude: \(lat), longitude: \(long)), altitude: \(altitude), horizontalAccuracy: \(hAccuracy), verticalAccuracy: \(vAccuracy), course: \(course), courseAccuracy: \(courseAccuracy), speed: \(speed), speedAccuracy: \(speedAccuracy), timestamp: Date(timeIntervalSinceReferenceDate: \(timeInterval)))
"""
        locationStrings.append(locationString)
    }
    
    print("Successfully processed \(locationStrings.count) locations")
    debugPrint("let locations: [CLLocation] = [\(locationStrings.joined(separator: ", "))]")
    return "let locations: [CLLocation] = [\(locationStrings.joined(separator: ", "))]"
}



