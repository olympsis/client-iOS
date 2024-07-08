//
//  RunningSplits.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/6/24.
//

import Charts
import SwiftUI

struct RunningSplits: View {
    
    var splits: [RunSplit]
    
    var body: some View {
        VStack {
            HStack {
                Text("Splits")
                    .textCase(.uppercase)
                    .foregroundStyle(.gray)
                Spacer()
            }.padding(.leading)
            ScrollView {                
                Chart(splits) { split in
                    BarMark(x: .value("Pace", Double(split.pace/60)), y: .value("Mile", String(split.id)))
                        .foregroundStyle(Color.colorSecnd)
                        .annotation(position: .leading) {
                            Text(String(format: "%.2f", Double(split.pace/60)))
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        .annotation(position: .trailing) {
                            HStack {
                                Text(String(split.elevation) + " ft")
                                Image(systemName: "mountain.2")
                                    .imageScale(.small)
                            }.padding(.horizontal)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .chartLegend(.hidden)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(preset: .extended, position: .leading)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    RunningSplits(
        splits: [
            RunSplit(id: 1, pace: 511, elevation: -3),
            RunSplit(id: 2, pace: 485, elevation: 10),
            RunSplit(id: 3, pace: 710, elevation: -30)
        ]
    )
}
