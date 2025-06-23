//
//  RunActivityGoalSetter.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct RunActivityGoalSetter: View {
    
    var goal: ACTIVITY_GOALS
    
    @State private var zone: Int = 0
    @State private var duration: Int = 5
    @State private var heartRate: Int = 100
    @State private var pace: Double = 9.30
    @State private var distance: Double = 1
    
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutManager.self) private var manager
    
    func secondsToMinutesSecondsFormat(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }

    
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    Task {
                        dismiss()
                    }
                }) {
                    Circle()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.colorPrime)
                        .overlay {
                            VStack {
                                Text("Start")
                                    .textCase(.uppercase)
                                    .italic()
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                            }
                        }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                switch goal {
                
                // MARK: - Distance
                case .distance:
                    Stepper(value: $distance, step: 0.1) {
                        Text(
                            Measurement(
                                value: distance,
                                unit: UnitLength.miles
                            )
                            .formatted(
                                .measurement(
                                    width: .abbreviated,
                                    usage: .road
                                )
                            )
                        )
                        .font(.title2)
                    }
                    
                // MARK: - Duration
                case .duration:
                    Stepper(value: $duration, step: 5) {
                        Text(secondsToMinutesSecondsFormat(seconds: duration))
                        .font(.title2)
                    }
                    
                // MARK: - Heart Rate
                case .heart_rate:
                    Stepper(value: $heartRate, step: 1) {
                        Text(String(heartRate))
                        .font(.title2)
                    }
                
                // MARK: - Pace
                case .pace:
                    Stepper(value: $pace, step: 0.05) {
                        Text("\(pace, specifier: "%.2f")")
                            .font(.title2)
                    }
                    
                // MARK: - Pace
                case .zone:
                    Stepper(value: $zone, in: 0...5,  step: 1) {
                        Text(String(zone))
                        .font(.title2)
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundStyle(Color.Background.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    RunActivityGoalSetter(goal: .zone)
        .environment(WorkoutManager())
}
