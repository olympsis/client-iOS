//
//  SmallWorkoutView.swift
//  Olympsis
//
//  Created by Joel on 10/16/23.
//

import SwiftUI
// import HealthKit

struct WorkoutListItem: View {
    
    @State var workout: Workout
    @State var event: Event?
    @State private var showDetails: Bool = false
    
    /// Computed property of the workout's name
    var workoutName: String {
        guard let e = event else {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: workout.workout.startDate)
            var timeOfDay: String

            if hour >= 0 && hour < 12 {
                timeOfDay = "Morning"
            } else if hour >= 12 && hour < 17 {
                timeOfDay = "Afternoon"
            } else {
                timeOfDay = "Evening"
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE" // EEEE will give you the full weekday name
            let dayOfWeek = dateFormatter.string(from: workout.workout.startDate)

            return "\(dayOfWeek.capitalized) \(timeOfDay) \(sportInString())"
        }
        return e.title
    }
    
    func sportInString() -> String {
        switch(workout.type) {
        case .running:
            return "Run"
        case .walking:
            return "Walk"
        case .cycling:
            return "Ride"
        case .soccer, .basketball, .football:
            return "Game"
        case .tennis, .volleyball:
            return "Match"
        default:
            return "Exercise"
        }
    }
    
    var body: some View {
        NavigationLink {
            WorkoutView(activityName: workoutName, workout: workout)
        } label: {
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 85, height: 85)
                    .foregroundStyle(Color.Foreground.default)
                    .overlay {
                        workout.type.icon()
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical)
                            .padding(.horizontal)
                            .foregroundStyle(Color.Background.primary)
                    }
                    .padding(.leading, 10)
                    
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(workout.dateToString)
                            .bold()
                            .foregroundStyle(Color.Foreground.default)
                        
                        Text(workoutName)
                            .foregroundStyle(.gray)
                    }.padding(.leading)
                        
                    
                    switch workout.type {
                    case .walking, .running:
                        HStack {
                            VStack(alignment: .center) {
                                Text("\(workout.totalDistance, specifier: "%.2f")")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.green)
                                
                                Text("Miles")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                                    .padding(.bottom, -5)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text(workout.averagePace)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                
                                Text("Avg Pace")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                                    .padding(.bottom, -5)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text(workout.totalTime)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.Brand.tertiary)
                                
                                Text("Time")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                                    .padding(.bottom, -5)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 1)
                    default:
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(workout.totalDistance, specifier: "%.2f")")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.green)
                                
                                Text("Miles")
                                    .font(.caption)
                                    .bold()
                                    .textCase(.uppercase)
                                    .padding(.bottom, -5)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("\(workout.totalCaloriesBurned, specifier: "%.0f")")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.Brand.secondary)
                                
                                Text("Calories")
                                    .font(.caption)
                                    .bold()
                                    .textCase(.uppercase)
                                    .padding(.bottom, -5)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text(workout.totalTime)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.Brand.tertiary)
                                
                                Text("Time")
                                    .font(.caption)
                                    .bold()
                                    .textCase(.uppercase)
                                    .padding(.bottom, -5)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 1)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color.Background.secondary)
            }
            
        }
    }
}

/* HealthKit disabled - Preview requires HKWorkout
#Preview {
    WorkoutListItem(workout: Workout(type: .soccer, workout: HKWorkout(activityType: .running, start: Calendar.current.date(byAdding: .second, value: -391, to: Date())!, end: Date())))
}
*/
