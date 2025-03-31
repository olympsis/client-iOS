//
//  NewEventParticipantsLimit.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventParticipantsLimit: View {
    
    @Bindable var manager: NewEventManager
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack {
            // MARK: - Min Participants slider
            VStack(alignment: .leading){
                Text("Min Participants")
                    .font(.title3)
                    .bold()
                Text("The minimum number of participants")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack {
//                    Slider(
//                        value: $manager.minParticipants,
//                        in: 0...100,
//                        step: 1.0,
//                        onEditingChanged: { editing in
//                            isEditing = editing
//                        }).padding(.horizontal)
                    
                    Text("TODO")
                        .foregroundColor(isEditing ? .red : .green)
//                    Stepper("", value: $manager.minParticipants, in: 0...100)
//                        .padding(.trailing)
                }.modifier(InputField())
                
            }
            .padding(.top)
            .padding(.horizontal)
            
            // MARK: - Max Participants slider
            VStack(alignment: .leading){
                Text("Max Participants")
                    .font(.title3)
                    .bold()
                Text("Limit the headcount")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack {
//                    Slider(
//                        value: $manager.maxParticipants,
//                        in: 0...1000,
//                        step: 5.0,
//                        onEditingChanged: { editing in
//                            isEditing = editing
//                        }).padding(.horizontal)
//                    
//                    Text("\(Int(manager.maxParticipants))")
//                        .foregroundColor(isEditing ? .red : .green)
//                    Stepper("", value: $manager.maxParticipants, in: 0...1000)
//                        .padding(.trailing)
                }.modifier(InputField())
            }
            .padding(.top)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    NewEventParticipantsLimit(manager: NewEventManager())
}
