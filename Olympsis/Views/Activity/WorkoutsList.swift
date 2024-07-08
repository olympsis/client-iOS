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
    @EnvironmentObject private var manager: WorkoutManager
    
    var body: some View {
        ScrollView {
            ForEach(manager.workouts.sorted(by: { $0.startDate > $1.startDate })) { workout in
                WorkoutListItem(workout: workout)
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
            .environmentObject(WorkoutManager())
    }
}
