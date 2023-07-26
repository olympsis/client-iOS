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
