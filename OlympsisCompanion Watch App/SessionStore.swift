//
//  SessionStore.swift
//  OlympsisCompanion Watch App
//
//  Created by Joel on 10/15/23.
//

import SwiftUI
import Foundation

@MainActor
class SessionStore: ObservableObject {
    
    @Published var selectedSport: Workout = workouts[0]
     let workoutSession = WorkoutSession()
    
}
