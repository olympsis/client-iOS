//
//  SmallWorkoutView.swift
//  Olympsis
//
//  Created by Joel on 10/16/23.
//

import SwiftUI

struct SmallWorkoutView: View {
    
    @State var workout: Workout
    @State var event: Event?
    @State private var showDetails: Bool = false
    
    /// Computed property of the workout's name
    var workoutName: Text {
        guard let e = event,
              let title = e.title else {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: workout.startDate)
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
            let dayOfWeek = dateFormatter.string(from: workout.startDate)

            return Text("\(dayOfWeek) \(timeOfDay) \(sportInString())").foregroundColor(.gray)
        }
        return Text("\(title)").foregroundColor(.gray)
    }
    
    var sportIcon: some View {
        switch (workout.type) {
        case .walking:
            return ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 85, height: 85)
                    .foregroundColor(.primary)
                Image(systemName: "figure.walk")
                    .resizable()
                    .frame(width: 30, height: 40)
                    .foregroundColor(.background)
            }
        case .running:
            return ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 85, height: 85)
                    .foregroundColor(.primary)
                Image(systemName: "figure.run")
                    .resizable()
                    .frame(width: 30, height: 40)
                    .foregroundColor(.background)
            }
        case .soccer:
            return ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 85, height: 85)
                    .foregroundColor(.primary)
                Image(systemName: "figure.soccer")
                    .resizable()
                    .frame(width: 30, height: 40)
                    .foregroundColor(.background)
            }
        }
    }
    
    func sportInString() -> String {
        switch(workout.type) {
        case .running:
            return "Run"
        case .walking:
            return "Walk"
        case .soccer:
            return "Exercise"
        }
    }
    
    var body: some View {
        HStack {
            sportIcon
                .padding(.leading)
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(workout.dateToString)
                        .bold()
                    workoutName
                }.padding(.leading)
                    
                
                switch workout.type {
                case .walking, .running:
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Miles")
                                .font(.caption)
                                .bold()
                                .padding(.bottom, -5)
                            Text("\(workout.totalDistanceTraveled, specifier: "%.2f")")
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Avg Pace")
                                .font(.caption)
                                .bold()
                                .padding(.bottom, -5)
                            Text(workout.averagePace)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Time")
                                .font(.caption)
                                .bold()
                                .padding(.bottom, -5)
                            Text(workout.ellapsedTime)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Calories")
                                .font(.caption)
                                .bold()
                                .padding(.bottom, -5)
                            Text("\(workout.caloriesBurned, specifier: "%.0f")")
                        }
                    }.padding(.horizontal)
                        .padding(.top, 1)
                case .soccer:
                    HStack {
                        VStack {
                            
                        }
                    }
                }
            }
            Spacer()
        }.frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("background"))
            }
            .padding(.horizontal, 5)
            .onTapGesture {
                self.showDetails.toggle()
            }
            .fullScreenCover(isPresented: $showDetails, content: {
                WorkoutView(activityName: workoutName, workout: workout)
            })
    }
}

#Preview {
    SmallWorkoutView(workout: Workout(id: UUID(), type: .running, startDate: Calendar.current.date(byAdding: .second, value: -391, to: Date())!, endDate: Date(), averageHeartRate: 155, caloriesBurned: 101, totalDistanceTraveled: 0.76))
}
