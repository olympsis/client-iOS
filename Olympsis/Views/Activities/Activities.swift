//
//  Activity.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/29/22.
//

import Charts
import SwiftUI
import HealthKit

struct Activities: View {
    
    @State private var showActivityView: Bool = false
    @State private var selectedFilter: Int = 0
    @Environment(SessionStore.self) private var session
    @Environment(WorkoutManager.self) private var manager
    
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                
                // Picks by which type to filter out the results
                ActivitiesTypePicker()
                    .padding(.top, 10)
                    .environment(manager)
                
                // Selects the frequency of which we want to see the results
                ActivitiesFrequencySelector(selectedFilter: $selectedFilter)
                    .padding(.bottom)
                    .padding(.top, 5)
                    .environment(manager)
                
                // Charts user activity metrics
                ActivitiesChart()
                    .environment(manager)
                
                // Displays a list of past user activities
                ActivitiesList()
                    .environment(manager)
                
                Spacer(minLength: 40)
            }
            .task {
                _ = await manager.requestHealthStoreAuthorization()
                guard manager.workouts.isEmpty else {
                    return
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(alignment: .top) {
                        Text("Activities")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("beta")
                            .font(.callout)
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
    }
}

#Preview {
    Activities()
        .environment(SessionStore())
        .environment(WorkoutManager())
}
