//
//  WorkoutSmallListItemView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/23/24.
//

import SwiftUI

struct WorkoutSmallListItemView: View {
    
    var workout: Workout
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(Color.foreground)
            .frame(height: 80)
            .overlay {
                VStack {
                    Text(workout.dateToString)
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                    
                    HStack {
                        switch workout.type {
                        case .running:
                            Image(systemName: "figure.run")
                                .fontWeight(.bold)
                                .imageScale(.large)
                        case .walking:
                            Image(systemName: "figure.walk")
                                .fontWeight(.bold)
                                .imageScale(.large)
                        case .cycling:
                            Image(systemName: "figure.outdoor.cycle")
                                .fontWeight(.bold)
                                .imageScale(.large)
                        case .soccer:
                            Image(systemName: "figure.soccer")
                                .fontWeight(.bold)
                                .imageScale(.large)
                        default:
                            Image(systemName: "figure")
                                .fontWeight(.bold)
                                .imageScale(.large)
                        }
                        
                        Text("\(workout.totalDistanceTraveled, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        Group {
                            Locale.current.measurementSystem == "Metric" ? Text("km") : Text("mi")
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                    }
                }
            }
    }
}

#Preview {
    WorkoutSmallListItemView(workout: Workout(id: UUID(), type: .soccer, startDate: Calendar.current.date(byAdding: .second, value: -391, to: Date())!, endDate: Date(), averageHeartRate: 155, caloriesBurned: 101, totalDistanceTraveled: 0.76))
}
