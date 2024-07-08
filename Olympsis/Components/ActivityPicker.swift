//
//  ActivityPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/3/24.
//

import SwiftUI

struct ActivityPicker: View {
    
    @State private var selectedSport: SPORTS?
    @EnvironmentObject private var workout: WorkoutManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(SPORTS.allCases, id: \.self) { sport in
                    SportView(sport: sport, scale: .Small)
                        .id(sport)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5) // Apply opacity animation
                                .scaleEffect(phase.isIdentity ? 1 : 0.7)
                        }
                        .frame(width: SCREEN_WIDTH/1.1)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $selectedSport)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 15)
        .frame(height: 100, alignment: .center)
        .overlay{
            HStack {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.large)
            }.padding(.horizontal)
        }
    }
}

#Preview {
    ActivityPicker()
        .environmentObject(SessionStore())
        .environmentObject(WorkoutManager())
}
