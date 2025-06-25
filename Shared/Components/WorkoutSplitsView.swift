//
//  WorkoutSplitsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/6/24.
//

import Charts
import SwiftUI

struct WorkoutSplitsView: View {
    
    var splits: [PaceSegment]
    
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
                    BarMark(
                        x: .value("Pace", split.pace / 60.0), 
                        y: .value("Split", "Split \(split.segmentNumber)")
                    )
                    .foregroundStyle(Color.colorSecnd)
                    .annotation(position: .leading) {
                        Text(formatPace(split.pace))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .annotation(position: .trailing) {
                        HStack {
                            Text(formatElevation(split.elevationGain - split.elevationLoss))
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
    
    /// Formats pace in seconds to MM:SS/unit format (e.g., "8:05/mi")
    private func formatPace(_ paceInSeconds: Double) -> String {
        let minutes = Int(paceInSeconds / 60)
        let seconds = Int(paceInSeconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d/mi", minutes, seconds)
    }
    
    /// Formats elevation change in meters to feet with sign
    private func formatElevation(_ elevationChangeInMeters: Double) -> String {
        let elevationInFeet = elevationChangeInMeters * 3.28084 // Convert meters to feet
        let sign = elevationInFeet >= 0 ? "+" : ""
        return String(format: "%@%.0f ft", sign, elevationInFeet)
    }
}

#Preview {
    let baseDate = Date()
    let split1 = PaceSegment(
        segmentNumber: 1, 
        distance: 1609.344, 
        duration: 511, 
        pace: 511, 
        elevationGain: 5, 
        elevationLoss: 8, 
        startTime: baseDate, 
        endTime: baseDate.addingTimeInterval(511)
    )
    let split2 = PaceSegment(
        segmentNumber: 2, 
        distance: 1609.344, 
        duration: 485, 
        pace: 485, 
        elevationGain: 12, 
        elevationLoss: 2, 
        startTime: baseDate.addingTimeInterval(511), 
        endTime: baseDate.addingTimeInterval(996)
    )
    let split3 = PaceSegment(
        segmentNumber: 3, 
        distance: 1609.344, 
        duration: 710, 
        pace: 710, 
        elevationGain: 2, 
        elevationLoss: 32, 
        startTime: baseDate.addingTimeInterval(996), 
        endTime: baseDate.addingTimeInterval(1706)
    )
    
    return WorkoutSplitsView(splits: [split1, split2, split3])
}
