//
//  WorkoutView.swift
//  Olympsis
//
//  Created by Joel on 10/17/23.
//

import SwiftUI

struct WorkoutView: View {
    
    @State var activityName: Text
    @State var workout: Workout
    @Environment(\.presentationMode) private var presentationMode
    
    var sportIcon: some View {
        switch (workout.type) {
        case .walking:
            return ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.primary)
                Image(systemName: "figure.walk")
                    .resizable()
                    .frame(width: 45, height: 55)
                    .foregroundColor(.background)
            }
        case .running:
            return ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.primary)
                Image(systemName: "figure.run")
                    .resizable()
                    .frame(width: 45, height: 55)
                    .foregroundColor(.background)
            }
        case .soccer:
            return ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.primary)
                Image(systemName: "figure.soccer")
                    .resizable()
                    .frame(width: 45, height: 55)
                    .foregroundColor(.background)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack {
                        sportIcon
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(workout.caloriesBurned, specifier: "%.0f")")
                                .font(.custom("ITCAvantGardeStd-BoldObl", size: 80))
                                .foregroundColor(Color("color-secnd"))
                            Text("Calories")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        }
                        Spacer()
                    }.frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    
                    switch (workout.type) {
                    case .walking, .running:
                        VStack {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(workout.averagePace)
                                        .foregroundColor(Color("color-secnd"))
                                        .font(.title3)
                                        .bold()
                                    Text("Avg. Pace")
                                }.frame(width: 100)
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text(workout.ellapsedTime)
                                        .foregroundColor(Color("color-secnd"))
                                        .font(.title3)
                                        .bold()
                                    Text("Time")
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("\(workout.totalDistanceTraveled, specifier: "%0.2f")")
                                        .foregroundColor(Color("color-secnd"))
                                        .font(.title3)
                                        .bold()
                                    Text("Miles")
                                }
                            }.padding(.horizontal, 25)
                                .padding(.vertical)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(workout.averageHeartRate, specifier: "%.0f")")
                                        .foregroundColor(Color("color-secnd"))
                                        .font(.title3)
                                        .bold()
                                    Text("Avg. Heart Rate")
                                }.frame(width: 100)
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("_")
                                        .foregroundColor(Color("color-secnd"))
                                        .font(.title3)
                                        .bold()
                                    Text("Cadence")
                                }.frame(width: 100)
                            }.padding(.horizontal, 25)
                        }
                    case .soccer:
                        HStack {}
                    }
                }.toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        activityName
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        WorkoutView(activityName: Text("Friday Evening Run"), workout: Workout(id: UUID(), type: .running, startDate: Calendar.current.date(byAdding: .second, value: -391, to: Date())!, endDate: Date(), averageHeartRate: 155, caloriesBurned: 101, totalDistanceTraveled: 0.76))
    }
}
