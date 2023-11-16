//
//  Workouts.swift
//  OlympsisCompanion Watch App
//
//  Created by Joel on 10/15/23.
//

import SwiftUI

struct Workouts: View {
    @Binding var selection: Int
    @EnvironmentObject var session: SessionStore
    func selectSport(workout: Workout) {
        withAnimation(.easeInOut) {
            selection = 1
            session.selectedSport = workout
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(workouts) { workout in
                    Button(action: { selectSport(workout: workout) } ) {
                        WorkoutView(workout: workout)
                    }.buttonStyle(.plain)
                    
                }
            } .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Workouts")
                }
            }
        }
    }
}

#Preview {
    Workouts(selection: .constant(0)).environmentObject(SessionStore())
}
