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
        case 2: // Current year workouts (January 1st to today)
            let calendar = Calendar.current
            let today = Date()
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: today)) ?? today
            return manager.workouts
                .filter { manager.sportFilter == nil ? true : $0.type == manager.sportFilter }
                .workoutsWithinDateInterval(interval: DateInterval(start: startOfYear, end: today))
        default: // Current week from Monday to today
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            dateComponents.weekday = 2 // Monday is weekday 2
            let mondayOfThisWeek = calendar.date(from: dateComponents) ?? Date()
            
            return manager.workouts
                .filter { manager.sportFilter == nil ? true : $0.type == manager.sportFilter }
                .workoutsWithinDateInterval(interval: DateInterval(start: mondayOfThisWeek, end: Date()))
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
                        BarMark(
                            x: .value("Day", data.dayAbbreviation()),
                            y: .value("Calories", data.count)
                        )
                    }
                }
                .frame(height: 200)
            } else if manager.frequencyFilter == 1 {
                Chart {
                    ForEach(workouts.totalCaloriesBurnedPerDayInMonth()) { data in
                        BarMark(
                            x: .value("Day", data.id),
                            y: .value("Calories", data.count)
                        )
                    }
                }
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(workouts.monthlyAverageCaloriesBurned()) { data in
                        BarMark(
                            x: .value("Month", data.monthAbbreviation()),
                            y: .value("Calories", data.count)
                        )
                    }
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
