//
//  ActivityHistory.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivityHistoryView: View {
    
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
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

#Preview {
    NavigationStack {
        ActivityHistoryView()
            .environment(WorkoutManager())
    }
}
