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
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    func notifyParticipants() async {
        status = .loading
        guard title != "",
            content != "",
              let id = event.id else {
            return
        }
        let resp = await session.eventObserver.notifyParticipants(id: id, title: title, body: content)
        if resp {
            status = .success
            self.presentationMode.wrappedValue.dismiss()
        }
        return
    }
    
    var body: some View {
        VStack {
            Text("What would you like to say to the participants?")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical)
            
            // MARK: - Title
            VStack(alignment: .leading){
                Text("Title")
                    .font(.title3)
                    .bold()
                Text("What is the nature of this notification?")
                    .font(.subheadline)
                
                TextField("Pick up reminder", text: $title)
                    .padding(.leading)
                    .modifier(MenuButton())
            }
            
            // MARK: - Content
            VStack(alignment: .leading){
                Text("Content")
                    .font(.title3)
                    .bold()
                Text("What do you want to tell them?")
                    .font(.subheadline)
                    
                
                TextField("Don't forget your gear", text: $content)
                    .padding(.leading)
                    .modifier(MenuButton())
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
        .environmentObject(SessionStore())
}
