//
//  ActivitiesTypePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/21/25.
//

import SwiftUI

struct ActivitiesTypePicker: View {

    @Environment(WorkoutManager.self) private var manager
    
    private var sports: [SUPPORTED_SPORTS] {
        var seen = Set<SUPPORTED_SPORTS>()
        return manager.workouts
            .sorted { $0.workout.startDate > $1.workout.startDate } // Most recent first
            .compactMap { workout in
                seen.insert(workout.type).inserted ? workout.type : nil
            }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button (action: { manager.sportFilter = nil }) {
                    Text("All")
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(manager.sportFilter == nil ? Color.Brand.primary : Color.primary)
                                .opacity(manager.sportFilter == nil ? 1 : 0.15)
                        }
                        .foregroundStyle(manager.sportFilter == nil ? Color.white : Color.primary)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary, lineWidth: 1)
                                .opacity(0.25)
                        }
                    
                }
                ForEach(sports, id: \.self) { sport in
                    Button(action: { manager.sportFilter = sport }) {
                        Text(sport.getName())
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(manager.sportFilter == sport ? Color.Brand.primary : Color.primary)
                                    .opacity(manager.sportFilter == sport ? 1 : 0.15)
                            }
                            .foregroundStyle(manager.sportFilter == sport ? Color.white : Color.primary)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primary, lineWidth: 1)
                                    .opacity(0.25)
                            }
                    }.padding(.vertical, 1)
                }
            }
        }.contentMargins(.horizontal, 10)
    }
}

#Preview {
    ActivitiesTypePicker()
        .environment(WorkoutManager())
}
