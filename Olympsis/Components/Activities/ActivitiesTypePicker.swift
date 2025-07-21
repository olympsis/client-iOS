//
//  ActivitiesTypePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/21/25.
//

import SwiftUI

struct ActivitiesTypePicker: View {
    
    @Binding var selectedType: String
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
                Button (action: { selectedType = "All" }) {
                    Text("All")
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(selectedType == "All" ? Color.Brand.primary : Color.primary)
                                .opacity(selectedType == "All" ? 1 : 0.15)
                        }
                        .foregroundStyle(selectedType == "All" ? Color.white : Color.primary)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary, lineWidth: 1)
                                .opacity(0.25)
                        }
                    
                }
                ForEach(sports, id: \.self) { sport in
                    Button(action: { selectedType = sport.getName() }) {
                        Text(sport.getName())
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(selectedType == sport.getName() ? Color.Brand.primary : Color.primary)
                                    .opacity(selectedType == sport.getName() ? 1 : 0.15)
                            }
                            .foregroundStyle(selectedType == sport.getName() ? Color.white : Color.primary)
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
    ActivitiesTypePicker(selectedType: .constant("All"))
        .environment(WorkoutManager())
}
