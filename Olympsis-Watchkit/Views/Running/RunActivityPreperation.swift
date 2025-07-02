//
//  RunActivityPreperation.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct RunActivityPreperation: View {
    
    var sport: SUPPORTED_SPORTS
    @State private var pickedGoal: ACTIVITY_GOALS?
    @State private var showGoalPicker: Bool = false
    @State private var showLiveActivity: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutManager.self) private var manager
    
    @AppStorage("run_type") private var runType: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                NavigationLink(destination: {
                    ActivityView(selectedSport: sport)
                        .environment(manager)
                }) {
                    Circle()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(Color.colorPrime)
                        .overlay {
                            VStack {
                                Text("Start")
                                    .textCase(.uppercase)
                                    .italic()
                                    .font(.system(size: 30))
                                    .fontWeight(.bold)
                            }
                        }
                }
                .buttonStyle(PlainButtonStyle())
                .onChange(of: manager.state, { oldValue, newValue in
                    if newValue == .ended {
                       dismiss()
                    }
                })
                
                // MARK: - Options
                VStack {
                    HStack {
                        Text("Goals")
                        Spacer()
                    }
                    
                    ForEach(ACTIVITY_GOALS.allCases, id: \.self) { goal in
                        NavigationLink {
                            switch sport {
                            case .running, .walking:
                                RunActivityGoalSetter(goal: goal)
                            default:
                                EmptyView()
                            }
                        } label: {
                            ActivityGoalButton(goal: goal)
                        }.buttonStyle(PlainButtonStyle())

                    }
                }
                .padding(.top)
                .scenePadding()
                .fullScreenCover(isPresented: $showLiveActivity, content: {
                    ActivityView(selectedSport: .running)
                })
            }
        }
    }
}

#Preview {
    RunActivityPreperation(sport: .running)
        .environment(WorkoutManager())
}
