//
//  Global Variables.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import UIKit
import Foundation
import SwiftUI

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

enum USER_STATUS {
    case New
    case Banned
    case Ubanned
    case Returning
    case Unknown
}


enum NavigationType: String, Hashable {
    case home = "HOME"
    case clubs = "CLUBS"
    case map = "MAP"
    case settings = "SETTINGS"
}


enum AuthNavigation: String, Hashable {
    case auth = "AUTH"
    case new = "NEW"
    case home = "HOME"
    case permissions = "PERMISSIONS"
    
}

enum LOADING_STATE {
    case pending
    case loading
    case success
    case failure
}

enum SPORT: String, CaseIterable {
    case soccer = "soccer"
    case volleyball = "volleyball"
    case basketball = "basketball"
    case pickleball = "pickleball"
    case tennis = "tennis"
    case golf = "golf"
    
    func Icon() -> String {
        switch self {
        case .soccer:
            return "⚽️"
        case .volleyball:
            return "🏐"
        case .basketball:
            return "🏀"
        case .pickleball:
            return "🏏"
        case .tennis:
            return "🎾"
        case .golf:
            return "⛳️"
        }
    }
    
    func Images() -> [String] {
        switch self {
        case .soccer:
            return ["soccer-0","soccer-1"]
        case .basketball:
            return ["basketball-0", "basketball-1", "basketball-2"]
        case .volleyball:
            return ["volleyball-0","volleyball-1","volleyball-2"]
        case .tennis:
            return ["tennis-0", "tennis-1", "tennis-2"]
        case .pickleball:
            return ["pickleball-0","pickleball-1","pickleball-2"]
        case .golf:
            return ["golf-0","golf-1","golf-2"]
        }
    }
}

func SportFromString(s: String) -> SPORT {
    switch s {
    case "soccer":
        return .soccer
    case "basketball":
        return .basketball
    case "pickleball":
        return .pickleball
    case "tennis":
        return .tennis
    case "golf":
        return .golf
    default:
        return .allCases[0]
    }
}

enum MEMBER_ROLES: String, CaseIterable {
    case Admin = "admin"
    case Moderator = "moderator"
    case Member = "member"
}

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
