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
            .foregroundStyle(Color.purple)
            .frame(height: 80)
            .overlay {
                VStack {
                    Text(workout.dateToString)
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                    
                    HStack {
                        workout.type.icon()
                            .fontWeight(.bold)
                            .imageScale(.large)
                        
                        Text("\(workout.totalDistance, specifier: "%.2f")")
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
    WorkoutSmallListItemView(workout: WORKOUTS[0])
}
