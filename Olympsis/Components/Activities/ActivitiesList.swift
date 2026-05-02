//
//  ActivitiesList.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/21/25.
//

import SwiftUI

struct ActivitiesList: View {
    
    @Environment(WorkoutManager.self) private var manager
    
    private var recentWorkouts: [Workout] {
        var arr: [Workout] = []
        switch manager.frequencyFilter {
        case 1: // The last month of workouts
            let start = Date()
            let end = Calendar.current.date(byAdding: .day, value: -30, to: start) ?? Date()
            arr = manager.workouts
                .sorted { $0.workout.startDate > $1.workout.startDate }
                .filter { manager.sportFilter == nil ? true : $0.type == manager.sportFilter }
                .workoutsWithinDateInterval(interval: DateInterval(start: end, end: start))
        case 2: // The last year worth of workouts
            let start = Date()
            let end = Calendar.current.date(byAdding: .day, value: -365, to: start) ?? Date()
            arr =  manager.workouts
                .sorted { $0.workout.startDate > $1.workout.startDate }
                .filter { manager.sportFilter == nil ? true : $0.type == manager.sportFilter }
                .workoutsWithinDateInterval(interval: DateInterval(start: end, end: start))
        default: // The last week of workouts
            let start = Date()
            let end = Calendar.current.date(byAdding: .day, value: -7, to: start) ?? Date()
            arr = manager.workouts
                .sorted { $0.workout.startDate > $1.workout.startDate }
                .filter { manager.sportFilter == nil ? true : $0.type == manager.sportFilter }
                .workoutsWithinDateInterval(interval: DateInterval(start: end, end: start))
        }
        return arr.count > 4 ? Array(arr[0..<4]) : arr
    }
    
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
            if (recentWorkouts.count > 0) {
                ForEach(recentWorkouts) { workout in
                    WorkoutListItem(workout: workout)
                        .padding(.horizontal)
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
