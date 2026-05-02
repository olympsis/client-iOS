//
//  NewEventParticipantsLimit.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventParticipantsSettings: View {
    
    @State private var isEditing: Bool = false
    @State private var allowWaitlist: Bool = false
    @State private var minParticipants: Double = 0
    @State private var maxParticipants: Double = 0
    @State private var hideParticipants: Bool = false
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    @Environment(NewEventManager.self) private var manager
    
    var body: some View {
        VStack {
            // MARK: - Min Participants slider
            VStack(alignment: .leading){
                Text(String(localized: "advanced-settings-min-participants-title", table: "Events"))
                    .font(.headline)
                    .bold()
                Text(String(localized: "advanced-settings-min-participants-sub-title", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack {
                    TextField(String(localized: "event-limit", table: "Events"), value: $minParticipants, formatter: formatter)
                        .keyboardType(.numberPad)
                        .padding(.leading)

                    Stepper("", value: $minParticipants, in: 0...100)
                        .padding(.trailing)
                }.modifier(InputFieldModifier())
                
            }.padding([.top, .horizontal])
            
            // MARK: - Max Participants slider
            VStack(alignment: .leading){
                Text(String(localized: "advanced-settings-max-participants-title", table: "Events"))
                    .font(.headline)
                    .bold()
                Text(String(localized: "advanced-settings-max-participants-sub-title", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack {
                    TextField(String(localized: "event-limit", table: "Events"), value: $maxParticipants, formatter: formatter)
                        .keyboardType(.numberPad)
                        .padding(.leading)

                    Stepper("", value: $maxParticipants, in: 0...1000)
                        .padding(.trailing)
                }.modifier(InputFieldModifier())
            }.padding([.top, .horizontal])
            
            
            // MARK: - Allow Waitlist
            VStack(alignment: .leading){
                Toggle(isOn: $allowWaitlist) {
                    Text(String(localized: "advanced-settings-waitlist-title", table: "Events"))
                        .font(.headline)
                        .bold()
                }
                Text(String(localized: "advanced-settings-waitlist-sub-title", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }.padding([.top, .horizontal])
            
            // MARK: - Hide Participants
            VStack(alignment: .leading){
                Toggle(isOn: $hideParticipants) {
                    Text(String(localized: "event-hide-participants-list", table: "Events"))
                        .font(.headline)
                        .bold()
                }
                Text(String(localized: "event-show-participants-after-rsvp", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }.padding([.top, .horizontal])
            
            Spacer()
        }
        .onAppear {
            // Setup with data from the manager if we already have set them.
            guard let config = manager.participantsConfig else { return }
            
            if let waitlist = config.hasWaitlist {
                allowWaitlist = waitlist
            }
            
            if let participants = config.hideParticipants {
                hideParticipants = participants
            }
            
            if let min = config.minParticipants {
                minParticipants = Double(min)
            }
            
            if let max = config.maxParticipants {
                maxParticipants = Double(max)
            }
        }
        .onDisappear {
            // Make sure we update the manager on dismissal of this view
            manager.participantsConfig = ParticipantsConfig(
                hasWaitlist: allowWaitlist,
                hideParticipants: hideParticipants ? true : nil,
                minParticipants: minParticipants > 0 ? Int(minParticipants) : nil,
                maxParticipants: maxParticipants > 0 ? Int(maxParticipants) : nil
            )
        }
    }
}

#Preview {
    NewEventParticipantsSettings()
        .environment(NewEventManager())
}
