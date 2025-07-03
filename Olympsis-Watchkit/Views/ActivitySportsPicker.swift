//
//  ActivitySportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivitySportsPicker: View {
    
    private var supportedSports: [SUPPORTED_SPORTS] {
        return SUPPORTED_SPORTS.allCases.filter({ $0 != .spike })
    }
    
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(supportedSports, id: \.self) { sport in
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
