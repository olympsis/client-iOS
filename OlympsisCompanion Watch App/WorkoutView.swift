//
//  WorkoutView.swift
//  OlympsisCompanion Watch App
//
//  Created by Joel on 10/20/23.
//

import SwiftUI
import Foundation

struct WorkoutView: View {
    @State var workout: Workout
    var body: some View {
        HStack {
            HStack {
                Image(systemName: workout.icon)
                    .imageScale(.large)
                Text(workout.name)
            }.padding(.leading)
                .padding(.vertical)
            Spacer()
        }.frame(maxWidth: .infinity)
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("color-secnd"))
        }
    }
}

#Preview {
    WorkoutView(workout: Workout(id: "001", name: "Outdoor Walk", icon: "figure.walk"))
}
