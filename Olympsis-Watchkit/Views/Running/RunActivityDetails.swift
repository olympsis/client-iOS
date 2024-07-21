//
//  ActivityDetails.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct RunActivityDetails: View {
    
    @EnvironmentObject private var manager: ActivityManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("calories")
                            .textCase(.uppercase)
                        Text(
                            Measurement (
                                value: manager.activeEnergy,
                                unit: UnitEnergy.kilocalories
                            ).formatted(
                                .measurement (
                                    width: .abbreviated,
                                    usage: .workout,
                                    numberFormatStyle: .number
                                )
                            )
                        )
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    }
                    
                    Image(systemName: "flame")
                        .foregroundStyle(.orange)
                        .imageScale(.large)
                        .padding([.bottom, .horizontal])
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text("splits")
                        .textCase(.uppercase)
                    
                    Rectangle()
                        .frame(height: 80)
                        .foregroundStyle(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text("elevation")
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
    RunActivityDetails()
        .environmentObject(ActivityManager())
}
