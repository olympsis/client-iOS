//
//  GlobalData.swift
//  OlympsisCompanion Watch App
//
//  Created by Joel on 10/15/23.
//

import SwiftUI
import Foundation

struct Workout: Identifiable {
    let id: String
    let name: String
    let icon: String
}

let workouts: [Workout] = [
    Workout(id: "001", name: "Outdoor Walk", icon: "figure.walk"),
    Workout(id: "002", name: "Running", icon: "figure.run"),
    Workout(id: "003", name: "Soccer", icon: "figure.soccer"),
    Workout(id: "004", name: "Tennis", icon: "figure.tennis"),
    Workout(id: "005", name: "Volleyball", icon: "figure.volleyball")
]
