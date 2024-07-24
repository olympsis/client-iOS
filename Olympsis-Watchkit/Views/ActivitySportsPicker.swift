//
//  ActivitySportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivitySportsPicker: View {
    
    @EnvironmentObject private var manager: WorkoutManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach([SPORTS.running, SPORTS.walking, SPORTS.soccer, SPORTS.tennis, SPORTS.pickleball], id: \.self) { sport in
                    NavigationLink(destination: ActivityPreparationView(sport: sport)) {
                        SportView(sport: sport, scale: .XLarge)
                            .frame(width: 130, height: 130)
                            .padding(.vertical)
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
        .environmentObject(WorkoutManager())
}
