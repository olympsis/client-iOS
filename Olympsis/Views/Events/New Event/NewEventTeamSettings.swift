//
//  NewEventTeamSettings.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/24/26.
//

import SwiftUI

struct NewEventTeamSettings: View {
    @State private var isEditing: Bool = false
    @State private var minTeams: Double = 0
    @State private var maxTeams: Double = 0
    @State private var maxTeamSize: Double = 0
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    @Environment(NewEventManager.self) private var manager
    
    var body: some View {
        VStack {
            // MARK: - Min Teams slider
            VStack(alignment: .leading){
                Text(String(localized: "advanced-settings-min-teams-title", table: "Events"))
                    .font(.headline)
                    .bold()
                Text(String(localized: "advanced-settings-min-teams-sub-title", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack {
                    TextField(String(localized: "event-limit", table: "Events"), value: $minTeams, formatter: formatter)
                        .keyboardType(.numberPad)
                        .padding(.leading)

                    Stepper("", value: $minTeams, in: 0...100)
                        .padding(.trailing)
                }.modifier(InputFieldModifier())
                
            }.padding([.top, .horizontal])
            
            // MARK: - Max Teams slider
            VStack(alignment: .leading){
                Text(String(localized: "advanced-settings-max-teams-title", table: "Events"))
                    .font(.headline)
                    .bold()
                Text(String(localized: "advanced-settings-max-teams-sub-title", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack {
                    TextField(String(localized: "event-limit", table: "Events"), value: $maxTeams, formatter: formatter)
                        .keyboardType(.numberPad)
                        .padding(.leading)

                    Stepper("", value: $maxTeams, in: 0...500)
                        .padding(.trailing)
                }.modifier(InputFieldModifier())
            }.padding([.top, .horizontal])
            
            // MARK: - Max Team Size slider
            VStack(alignment: .leading){
                Text(String(localized: "advanced-settings-max-team-size-title", table: "Events"))
                    .font(.headline)
                    .bold()
                Text(String(localized: "advanced-settings-max-team-size-sub-title", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack {
                    TextField(String(localized: "event-limit", table: "Events"), value: $maxTeamSize, formatter: formatter)
                        .keyboardType(.numberPad)
                        .padding(.leading)

                    Stepper("", value: $maxTeamSize, in: 0...100)
                        .padding(.trailing)
                }.modifier(InputFieldModifier())
            }.padding([.top, .horizontal])
            
            Spacer()
        }
        .background {
            Color.Background.primary.ignoresSafeArea()
        }
        .onAppear {
            // Setup with data from the manager if we already have set them.
            guard let config = manager.teamsConfig else { return }
            
            
            if let min = config.minTeams {
                minTeams = Double(min)
            }
            
            if let max = config.maxTeams {
                maxTeams = Double(max)
            }
            
            if let maxSize = config.maxTeamSize {
                maxTeamSize = Double(maxSize)
            }
        }
        .onDisappear {
            manager.teamsConfig = TeamsConfig(
                minTeams: minTeams > 0 ? Int32(minTeams) : nil,
                maxTeams: maxTeams > 0 ? Int32(maxTeams) : nil,
                maxTeamSize: maxTeamSize > 0 ? Int32(maxTeamSize) : nil
            )
        }
    }
}

#Preview {
    NewEventTeamSettings()
        .environment(NewEventManager())
}
