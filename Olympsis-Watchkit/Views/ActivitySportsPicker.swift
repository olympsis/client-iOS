//
//  ActivitySportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivitySportsPicker: View {
    
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach([SUPPORTED_SPORTS.running, SUPPORTED_SPORTS.walking, SUPPORTED_SPORTS.soccer, SUPPORTED_SPORTS.tennis, SUPPORTED_SPORTS.pickleball], id: \.self) { sport in
                    NavigationLink(destination: ActivityPreparationView(sport: sport)) {
                        ActivitySportCard(sport: sport)
                            .frame(height: 150)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .task {
                #if !targetEnvironment(simulator)
                await manager.requestHealthStoreAuthorization()
                #endif
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Activities")
                }
            }
        }
    }
}

#Preview {
    ActivitySportsPicker()
        .environment(WorkoutManager())
}
