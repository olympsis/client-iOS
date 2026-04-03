//
//  EventNotification.swift
//  Olympsis
//
//  Created by Joel on 11/15/23.
//

import SwiftUI

struct EventNotification: View {
    
    @State var event: Event
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var status: LOADING_STATE = .pending
    @Environment(SessionStore.self) private var session
    @Environment(\.presentationMode) private var presentationMode
    
    func notifyParticipants() async {
        status = .loading
        guard title != "",
            content != "" else {
            return
        }
        let resp = await session.eventObserver.notifyParticipants(id: event.id, title: title, body: content)
        if resp {
            status = .success
            self.presentationMode.wrappedValue.dismiss()
        }
        return
    }
    
    var body: some View {
        VStack {
            Text(String(localized: "event-notification-prompt", table: "Events"))
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical)
            
            // MARK: - Title
            VStack(alignment: .leading){
                Text(String(localized: "event-notification-title-label", table: "Events"))
                    .font(.title3)
                    .bold()
                Text(String(localized: "event-notification-title-hint", table: "Events"))
                    .font(.subheadline)
                
                TextField(String(localized: "event-notification-title-placeholder", table: "Events"), text: $title)
                    .padding(.leading)
                    
            }
            
            // MARK: - Content
            VStack(alignment: .leading){
                Text(String(localized: "event-notification-content-label", table: "Events"))
                    .font(.title3)
                    .bold()
                Text(String(localized: "event-notification-content-hint", table: "Events"))
                    .font(.subheadline)
                    
                
                TextField(String(localized: "event-notification-content-placeholder", table: "Events"), text: $content)
                    .padding(.leading)
                    
            }
            
            Spacer()
            
            // MARK: - Action Button
            VStack(alignment: .center){
                Button(action: { Task { await notifyParticipants() } }) {
                    LoadingButton(text: "Send", width: 150, status: $status)
                }
            }.padding(.top, 50)
        }
    }
}

#Preview {
    EventNotification(event: EVENTS[0])
        .environment(SessionStore())
}
