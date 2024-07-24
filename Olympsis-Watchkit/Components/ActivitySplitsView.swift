//
//  SplitsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/21/24.
//

import Charts
import SwiftUI

struct ActivitySplitsView: View {
    
    @EnvironmentObject private var manager: WorkoutManager
    
    var body: some View {
        Text("")
//        Chart(splits) { split in
//            BarMark(x: .value("Pace", Double(split.pace/60)), y: .value("Mile", String(split.id)))
//                .foregroundStyle(Color.colorSecnd)
//                .annotation(position: .leading) {
//                    Text(String(format: "%.2f", Double(split.pace/60)))
//                        .foregroundColor(.gray)
//                        .padding(.horizontal)
//                }
//                .clipShape(RoundedRectangle(cornerRadius: 5))
//        }
//        .chartLegend(.hidden)
//        .chartXAxis(.hidden)
//        .chartYAxis {
//            AxisMarks(preset: .extended, position: .leading)
//        }
    }
}

#Preview {
    let manager = WorkoutManager()
    return ActivitySplitsView()
        .environmentObject(manager)
}
