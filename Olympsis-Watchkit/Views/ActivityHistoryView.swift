//
//  ActivityHistory.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivityHistoryView: View {
    
    @EnvironmentObject private var manager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(manager.workouts) { workout in
                    WorkoutSmallListItemView(workout: workout)
                }
                
                Text("To see more workout details check the Olympsis application.")
                    .foregroundStyle(.gray)
                    .font(.caption)
                    .padding(.vertical)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("History")
                }
            }
        }
    }
}

#Preview {
    ActivityHistoryView()
        .environmentObject(WorkoutManager())
}
