//
//  NewEventAdvancedSettings.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventAdvancedSettings: View {
    
    @Bindable var manager: NewEventManager
    
    @State private var showLimitParticipants: Bool = false
    @State private var showExternalLinkField: Bool = false
    @State private var showRecurringEventSettings: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }.padding(.leading)
                
                Spacer()
                Spacer()
                
                Text("Advanced Settings")
                    .fontWeight(.bold)
                
                Spacer()
                Spacer()
                Spacer()
            }
            
            ScrollView {
                MenuButton(icon: Image(systemName: "person.2.badge.minus.fill"), text: "Limit Participants") { showLimitParticipants.toggle()
                }
                
                MenuButton(icon: Image(systemName: "link"), text: "External Link") {
                    showExternalLinkField.toggle()
                }
                
                MenuButton(icon: Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90"), text: "Recurring Event") {
                    showRecurringEventSettings.toggle()
                }
            }
            .sheet(isPresented: $showLimitParticipants) {
                NewEventParticipantsLimit(manager: manager)
                    .presentationDetents([.height(250)])
            }
            .sheet(isPresented: $showExternalLinkField) {
                NewEventExternalLink(manager: manager)
                    .presentationDetents([.height(250)])
            }
            .sheet(isPresented: $showRecurringEventSettings) {
                NewEventRecurringSettings(manager: manager)
                    .presentationDetents([.height(250)])
            }
            
        }.background(Color.Background.primary)
    }
}

#Preview {
    NewEventAdvancedSettings(manager: NewEventManager())
}
