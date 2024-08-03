//
//  Activity.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/29/22.
//

import Charts
import SwiftUI
import HealthKit

struct Activity: View {
    
    @State private var showActivityView: Bool = false
    @State private var selectedSport: SPORTS?
    @State private var selectedFilter: Int = 0
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                HStack {
                    Button(action: {
                        withAnimation(.interpolatingSpring) {
                            selectedFilter = 0
                            Task {
                                await manager.fetchWorkoutsHistory(in: manager.weekPredicate.predicateFormat)
                            }
                        }
                    }){
                        Text("Week")
                            .foregroundColor(selectedFilter == 0 ? .white : .primary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background {
                        if selectedFilter == 0 {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("color-secnd"))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("color-secnd"), lineWidth: 1.0)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.interpolatingSpring) {
                            selectedFilter = 1
                            Task {
                                await manager.fetchWorkoutsHistory(in: manager.monthPredicate.predicateFormat)
                            }
                        }
                    }){
                        if selectedFilter == 1 {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("color-secnd"))
                                .overlay {
                                    Text("Month")
                                        .foregroundColor(selectedFilter == 1 ? .white : .primary)
                                }
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("color-secnd"), lineWidth: 1.0)
                                .overlay {
                                    Text("Month")
                                        .foregroundColor(selectedFilter == 1 ? .white : .primary)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.interpolatingSpring) {
                            selectedFilter = 2
                            Task {
                                await manager.fetchWorkoutsHistory(in: manager.yearPredicate.predicateFormat)
                            }
                        }
                    }){
                        if selectedFilter == 2 {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("color-secnd"))
                                .overlay {
                                    Text("Year")
                                        .foregroundColor(selectedFilter == 2 ? .white : .primary)
                                }
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("color-secnd"), lineWidth: 1.0)
                                .overlay {
                                    Text("Year")
                                        .foregroundColor(selectedFilter == 2 ? .white : .primary)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 10)
                .padding(.vertical)
                
                switch manager.viewState {
                case .pending, .success:
                    VStack(alignment: .leading) {
                        Text(totalCaloriesBurned)
                            .font(.largeTitle)
                            .bold()
                        Text("Calories")
                            .font(.title3)
                        
                        if selectedFilter == 0 {
                            Chart {
                                ForEach(manager.workouts.totalCaloriesBurnedPerDay()) { data in
                                    LineMark(
                                        x: .value("Day", data.dayAbbreviation()),
                                        y: .value("Calories", data.count)
                                    )
                                    .interpolationMethod(.cardinal)
                                    .symbol(by: .value("Workout Type", "Running"))
                                }
                                
                                ForEach(manager.workouts.totalCaloriesBurnedPerDay()) { data in
                                    AreaMark(x: .value("Day", data.dayAbbreviation()),
                                             y: .value("Calories", data.count))
                                }
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(linearGradient)
                            }
                            .frame(height: 200)
                        } else if selectedFilter == 1 {
                            Chart {
                                ForEach(manager.workouts.totalCaloriesBurnedPerDayInMonth()) { data in
                                    LineMark(
                                        x: .value("Day", data.id),
                                        y: .value("Calories", data.count)
                                    )
                                    .interpolationMethod(.cardinal)
                                    .symbol(by: .value("Workout Type", "Running"))
                                }
                                
                                ForEach(manager.workouts.totalCaloriesBurnedPerDayInMonth()) { data in
                                    AreaMark(x: .value("Day", data.dayAbbreviation()),
                                             y: .value("Calories", data.count))
                                }
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(linearGradient)
                            }
                            .frame(height: 200)
                        } else {
                            Chart {
                                ForEach(manager.workouts.monthlyAverageCaloriesBurned()) { data in
                                    LineMark(
                                        x: .value("Month", data.monthAbbreviation()),
                                        y: .value("Calories", data.count)
                                    )
                                    .interpolationMethod(.cardinal)
                                    .symbol(by: .value("Workout Type", "Running"))
                                }
                                
                                ForEach(manager.workouts.monthlyAverageCaloriesBurned()) { data in
                                    AreaMark(x: .value("Day", data.monthAbbreviation()),
                                             y: .value("Calories", data.count))
                                }
                                .interpolationMethod(.cardinal)
                                .foregroundStyle(linearGradient)
                            }
                            .frame(height: 200)
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Text("Activities")
                            .font(.system(.headline))
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        NavigationLink {
                            WorkoutsList(title: "Workouts")
                        } label: {
                            Text("View All")
                                .bold()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .foregroundColor(Color.primary)
                        
                    }
                    if (manager.workouts.count > 0) {
                        ForEach(manager.workouts.sorted(by: { $0.workout.startDate > $1.workout.startDate }).prefix(4)) { workout in
                            WorkoutListItemView(workout: workout)
                        }
                    } else {
                        Text("😤")
                        Text("Couldn't find any recent activities")
                    }
                    
                case .loading:
                    VStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 200)
                            .padding(.all)
                            .foregroundStyle(.gray)
                        
                        HStack {
                            Text("Activities")
                                .font(.system(.headline))
                                .padding(.horizontal)
                            Spacer()
                            
                            NavigationLink {
                                WorkoutsList(title: "Workouts")
                            } label: {
                                Text("View All")
                                    .bold()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .disabled(true)
                            .foregroundColor(Color.primary)
                            
                        }
                        
                        LazyVStack {
                            ForEach(0..<5, id: \.self) { _ in
                                WorkoutListItemTemplate()
                            }
                        }
                    }
                    .disabled(true)
                    .redacted(reason: .placeholder)
                case .failure:
                    Text("😭")
                    Text("Failed to get workouts")
                }
                
                Spacer(minLength: 40)
            }
            .task {
                guard manager.workouts.isEmpty else {
                    return
                }
                await manager.requestHealthStoreAuthorization()
                await manager.fetchWorkoutsHistory(in: manager.weekPredicate.predicateFormat)
            }
            .onChange(of: manager.state, { oldValue, newValue in
                if newValue == .active {
                    showActivityView = true
                }
            })
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("Activity")
                            .font(.title)
                            .bold()
                            .foregroundColor(.primary)
                        
                        Text("beta")
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
    }
}

struct Activity_Previews: PreviewProvider {
    static var previews: some View {
        Activity().environment(SessionStore())
    }
}
