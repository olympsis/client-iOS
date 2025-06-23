//
//  GeneralActivityDetails.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/21/24.
//

import SwiftUI

struct GeneralActivityDetails: View {
    
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                VStack(alignment: .leading) {
                    Text("BPM")
                        .textCase(.uppercase)
                    
                    Rectangle()
                        .frame(height: 80)
                        .foregroundStyle(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text("zones")
                        .textCase(.uppercase)
                    
                    Rectangle()
                        .frame(height: 80)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

#Preview {
    GeneralActivityDetails()
        .environment(WorkoutManager())
}
