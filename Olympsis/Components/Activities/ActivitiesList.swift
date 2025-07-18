//
//  ActivitiesList.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/21/25.
//

import SwiftUI

struct ActivitiesList: View {
    
    @Environment(WorkoutManager.self) private var manager
    var body: some View {
        VStack {
            HStack {
                Text("Activities")
                    .font(.system(.headline))
                    .padding(.horizontal)
                
                Spacer()
                
                NavigationLink {
                    WorkoutsList(title: "Workouts")
                } label: {
                    Text("View All")
                        .bold()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .foregroundColor(Color.primary)
                
            }
            if (manager.workouts.count > 0) {
                LazyVStack {
                    ForEach(manager.workouts.sorted(by: { $0.workout.startDate > $1.workout.startDate }).prefix(4)) { workout in
                        WorkoutListItem(workout: workout)
                            .padding(.horizontal)
                    }
                }
            } else {
                Text("Couldn't find any recent activities 😤")
                    .padding(.top)
            }
        }
    }
}

#Preview {
    ActivitiesList()
        .environment(WorkoutManager())
}
