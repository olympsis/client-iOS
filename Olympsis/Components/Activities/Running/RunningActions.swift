//
//  ActiveRunningActions.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/6/24.
//

import SwiftUI

struct RunningActions: View {
    
    @Binding var selectedTab: WORKOUT_TABS
    @EnvironmentObject private var manager: WorkoutManager
    
    var body: some View {
        HStack {
            if manager.workoutState == .active {
                Button(action: {
                    withAnimation {
                        selectedTab = .settings
                    }
                }) {
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.background)
                        .shadow(radius: 3, x: 0, y: 10)
                        .overlay {
                            Image(systemName: "gearshape.fill")
                                .imageScale(.large)
                                .foregroundStyle(Color.foreground)
                        }
                }
                
                Button(action: {
                    withAnimation {
                        manager.workoutState = .paused
                    }
                }) {
                    Circle()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.colorSecnd)
                        .overlay {
                            Image(systemName: "pause.fill")
                                .foregroundStyle(.white)
                                .imageScale(.large)
                        }
                }.padding(.horizontal, 30)
                
                Button(action: {
                    withAnimation {
                        selectedTab = .advanced_metrics
                    }
                }) {
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.background)
                        .shadow(radius: 3, x: 0, y: 10)
                        .overlay {
                            Image(systemName: "chart.bar.fill")
                                .imageScale(.medium)
                                .foregroundStyle(Color.foreground)
                        }
                }
            } else if manager.workoutState == .paused {
                Button(action: {
                    withAnimation {
                        manager.workoutState = .ended
                    }
                }) {
                    Circle()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.foreground)
                        .overlay {
                            Image(systemName: "square.fill")
                                .foregroundStyle(.white)
                                .imageScale(.large)
                        }
                }
                
                Button(action: {
                    withAnimation {
                        selectedTab = .advanced_metrics
                    }
                }) {
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.background)
                        .shadow(radius: 3, x: 0, y: 10)
                        .overlay {
                            Image(systemName: "chart.bar.fill")
                                .imageScale(.medium)
                                .foregroundStyle(Color.colorPrime)
                        }
                }.padding(.horizontal, 30)
                
                Button(action: {
                    withAnimation {
                        manager.workoutState = .active
                    }
                }) {
                    Circle()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.colorSecnd)
                        .overlay {
                            Image(systemName: "play.fill")
                                .foregroundStyle(.white)
                                .imageScale(.large)
                        }
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let manager = WorkoutManager()
    manager.workoutState = .paused
    return RunningActions(selectedTab: .constant(.metrics))
        .environmentObject(manager)
}
