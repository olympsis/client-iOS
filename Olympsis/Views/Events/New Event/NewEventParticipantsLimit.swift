//
//  NewEventParticipantsLimit.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventParticipantsLimit: View {
    
    @State private var isEditing: Bool = false
    @State private var allowWaitlist: Bool = false
    @State private var minParticipants: Double = 0
    @State private var maxParticipants: Double = 0
    
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
                Text("Min Participants")
                    .font(.headline)
                    .bold()
                Text("Least number of participants required")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack {
                    TextField("Limit", value: $minParticipants, formatter: formatter)
                        .keyboardType(.numberPad)
                        .padding(.leading)

                    Stepper("", value: $minParticipants, in: 0...100)
                        .padding(.trailing)
                }.modifier(InputField())
                
            }.padding([.top, .horizontal])
            
            // MARK: - Max Participants slider
            VStack(alignment: .leading){
                Text("Max Participants")
                    .font(.headline)
                    .bold()
                Text("Set the event's participants capacity")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack {
                    TextField("Limit", value: $maxParticipants, formatter: formatter)
                        .keyboardType(.numberPad)
                        .padding(.leading)

                    Stepper("", value: $maxParticipants, in: 0...1000)
                        .padding(.trailing)
                }.modifier(InputField())
            }.padding([.top, .horizontal])
            
            
            // MARK: - Allow Waitlist
            VStack(alignment: .leading){
                Toggle(isOn: $allowWaitlist) {
                    Text("Allow Waitlist")
                        .font(.headline)
                        .bold()
                }
                Text("If the number of participants exceeds the capacity, allow them to join a waitlist")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }.padding([.top, .horizontal])
            
            Spacer()
        }
        .onDisappear {
            if (minParticipants != 0 || maxParticipants != 0 || allowWaitlist) {
                manager.participantsConfig = ParticipantsConfig(
                    hasWaitlist: allowWaitlist,
                    minParticipants: Int(minParticipants),
                    maxParticipants: Int(maxParticipants)
                )
            }
        }
    }
}

#Preview {
    NewEventParticipantsLimit()
        .environment(NewEventManager())
}
