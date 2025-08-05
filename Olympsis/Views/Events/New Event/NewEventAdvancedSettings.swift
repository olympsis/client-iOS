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
            HStack {
                Text(String(localized: "advanced-settings-title", table: "Events"))
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                }
            }.padding(.horizontal)
            
            ScrollView {
                MenuButton(icon: Image(systemName: "slider.vertical.3"), text: String(localized: "advanced-settings-formatting", table: "Events")) {
                    showEventFormat.toggle()
                }.padding(.top)
                
                MenuButton(icon: Image(systemName: "person.2.badge.minus.fill"), text: String(localized: "advanced-settings-participants", table: "Events")) {
                    showLimitParticipants.toggle()
                }
                
                MenuButton(icon: Image(systemName: "link"), text: String(localized: "advanced-settings-external-link", table: "Events")) {
                    showExternalLinkField.toggle()
                }
                
                MenuButton(icon: Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90"), text: String(localized: "advanced-settings-recurring", table: "Events")) {
                    showRecurringEventSettings.toggle()
                }
            }
            .sheet(isPresented: $showEventFormat) {
                NewEventFormatting()
                    .environment(manager)
                    .presentationDetents([.height(350)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showLimitParticipants) {
                NewEventParticipantsSettings()
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
    }
}

#Preview {
    NewEventAdvancedSettings()
        .environment(SessionStore())
        .environment(NewEventManager())
}
