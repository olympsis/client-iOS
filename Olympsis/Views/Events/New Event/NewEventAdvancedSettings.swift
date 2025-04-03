//
//  NewEventAdvancedSettings.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventAdvancedSettings: View {
    
    @State private var showEventFormat: Bool = false
    @State private var showLimitParticipants: Bool = false
    @State private var showExternalLinkField: Bool = false
    @State private var showRecurringEventSettings: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    @Environment(NewEventManager.self) private var manager
    
    var body: some View {
        VStack {
            ScrollView {
                MenuButton(icon: Image(systemName: "slider.vertical.3"), text: "Event Formatting") {
                    showEventFormat.toggle()
                }.padding(.top)
                
                MenuButton(icon: Image(systemName: "person.2.badge.minus.fill"), text: "Limit Participants") {
                    showLimitParticipants.toggle()
                }
                
                MenuButton(icon: Image(systemName: "link"), text: "External Link") {
                    showExternalLinkField.toggle()
                }
                
                MenuButton(icon: Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90"), text: "Recurring Event") {
                    showRecurringEventSettings.toggle()
                }
            }
            .sheet(isPresented: $showEventFormat) {
                NewEventFormatting()
                    .environment(manager)
                    .presentationDetents([.height(150)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showLimitParticipants) {
                NewEventParticipantsLimit()
                    .environment(manager)
                    .presentationDetents([.height(350)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showExternalLinkField) {
                NewEventExternalLink()
                    .environment(manager)
                    .presentationDetents([.height(150)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showRecurringEventSettings) {
                NewEventRecurringSettings()
                    .environment(manager)
                    .presentationDetents([.height(350)])
                    .presentationDragIndicator(.visible)
            }
            
        }
        .navigationTitle("Advanced Settings")
    }
}

#Preview {
    NewEventAdvancedSettings()
        .environment(SessionStore())
        .environment(NewEventManager())
}
