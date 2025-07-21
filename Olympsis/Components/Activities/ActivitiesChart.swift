//
//  ActivitiesChart.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/21/25.
//

import Charts
import SwiftUI

struct ActivitiesChart: View {

    private var workouts: [Workout] {
        switch manager.frequencyFilter {
        case 1: // The last month of workouts
            let start = Date()
            let end = Calendar.current.date(byAdding: .day, value: -30, to: start) ?? Date()
            return manager.workouts
                .filter { manager.sportFilter == nil ? true : $0.type == manager.sportFilter }
                .workoutsWithinDateInterval(interval: DateInterval(start: end, end: start))
        case 2: // The last year worth of workouts
            let start = Date()
            let end = Calendar.current.date(byAdding: .day, value: -365, to: start) ?? Date()
            return manager.workouts
                .filter { manager.sportFilter == nil ? true : $0.type == manager.sportFilter }
                .workoutsWithinDateInterval(interval: DateInterval(start: end, end: start))
        default: // The last week of workouts
            let start = Date()
            let end = Calendar.current.date(byAdding: .day, value: -7, to: start) ?? Date()
            return manager.workouts
                .filter { manager.sportFilter == nil ? true : $0.type == manager.sportFilter }
                .workoutsWithinDateInterval(interval: DateInterval(start: end, end: start))
        }
    }
    
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(workouts.calculateTotalCalories()))
                .font(.custom("Archivo-BlackItalic", size: 60, relativeTo: .largeTitle))
            Text("Calories")
                .font(.title3)
            
            if manager.frequencyFilter == 0 {
                Chart {
                    ForEach(workouts.totalCaloriesBurnedPerDay()) { data in
                        LineMark(
                            x: .value("Day", data.dayAbbreviation()),
                            y: .value("Calories", data.count)
                        )
                        .interpolationMethod(.cardinal)
                        .symbol(by: .value("Workout Type", "Running"))
                    }
                    
                    ForEach(workouts.totalCaloriesBurnedPerDay()) { data in
                        AreaMark(x: .value("Day", data.dayAbbreviation()),
                                 y: .value("Calories", data.count))
                    }
                    .interpolationMethod(.cardinal)
//                                .foregroundStyle(linearGradient)
                }
                .frame(height: 200)
            } else if manager.frequencyFilter == 1 {
                Chart {
                    ForEach(workouts.totalCaloriesBurnedPerDayInMonth()) { data in
                        LineMark(
                            x: .value("Day", data.id),
                            y: .value("Calories", data.count)
                        )
                        .interpolationMethod(.cardinal)
                        .symbol(by: .value("Workout Type", "Running"))
                    }
                    
                    ForEach(workouts.totalCaloriesBurnedPerDayInMonth()) { data in
                        AreaMark(x: .value("Day", data.dayAbbreviation()),
                                 y: .value("Calories", data.count))
                    }
                    .interpolationMethod(.cardinal)
//                                .foregroundStyle(linearGradient)
                }
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(workouts.monthlyAverageCaloriesBurned()) { data in
                        LineMark(
                            x: .value("Month", data.monthAbbreviation()),
                            y: .value("Calories", data.count)
                        )
                        .interpolationMethod(.cardinal)
                        .symbol(by: .value("Workout Type", "Running"))
                    }
                    
                    ForEach(workouts.monthlyAverageCaloriesBurned()) { data in
                        AreaMark(x: .value("Day", data.monthAbbreviation()),
                                 y: .value("Calories", data.count))
                    }
                    .interpolationMethod(.cardinal)
//                                .foregroundStyle(linearGradient)
                }
                .frame(height: 200)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ActivitiesChart()
        .environment(WorkoutManager())
}
