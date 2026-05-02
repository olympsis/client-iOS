//
//  WorkoutsList.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/7/24.
//

import SwiftUI

struct WorkoutsList: View {
    
    var title: String
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutManager.self) var manager: WorkoutManager
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(manager.workouts.sorted(by: { $0.workout.startDate > $1.workout.startDate })) { workout in
                    WorkoutListItem(workout: workout)
                }
            }
        }
        .contentMargins(.vertical, 10)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(title)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutsList(title: "Workouts")
            .environment(WorkoutManager())
    }
}
