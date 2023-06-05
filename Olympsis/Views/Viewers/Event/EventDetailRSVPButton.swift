//
//  EventDetailRSVPActions.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventDetailRSVPButton: View {
    
    @Binding var event: Event
    @State private var state: LOADING_STATE = .pending
    @EnvironmentObject var session:SessionStore
    
    func rsvp(status: String) async {
        state = .loading
        guard let user = session.user,
              let uuid = user.uuid else {
                  return
              }
        
        let participant = Participant(id: nil, uuid: uuid, data: nil, status: status, createdAt: nil)
        let resp = await session.eventObserver.addParticipant(id: event.id!, participant)
        
        guard resp == true,
            let id = event.id,
            let update = await session.eventObserver.fetchEvent(id: id) else {
            state = .failure
            return
        }
        self.event = update
        state = .success
    }
    
    func cancel() async {
        state = .loading
        guard let id = event.id,
            let user = session.user,
              let uuid = user.uuid,
              let participants = event.participants,
            let participantID = participants.first(where: { $0.uuid == uuid })?.id else {
            return
        }
        
        let resp = await session.eventObserver.removeParticipant(id: id, pid: participantID)
        guard resp == true,
            let id = event.id,
            let update = await session.eventObserver.fetchEvent(id: id) else {
            state = .failure
            return
        }
        self.event = update
        state = .success
    }
    
    var hasResponded: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let participants = event.participants else {
            return false
        }
        return participants.first(where: { $0.uuid == uuid }) != nil
    }
    
    var body: some View {
        VStack {
            if event.status == "pending" {
                if !hasResponded {
                    Menu {
                        Button(action: { Task{  await rsvp(status: "not sure") } }) {
                            Text("Not Sure")
                        }
                        Button(action:{ Task { await rsvp(status: "going") } }){
                            Text("I'm Going")
                        }
                    } label: {
                        ZStack {
                            Image(systemName: "envelope.open.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .contrast(state == .loading ? 0 : 1)
                                .foregroundColor(Color("primary-color"))
                            if state == .loading {
                                ProgressView()
                            }
                        }
                    }.disabled(state == .loading ? true : false)
                } else {
                    Button(action:{ Task{ await cancel() }}){
                        ZStack {
                            Image(systemName: "x.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .contrast(state == .loading ? 0 : 1)
                                .foregroundColor(.red)
                            if state == .loading {
                                ProgressView()
                            }
                        }
                    }.disabled(state == .loading ? true : false)
                }
            }
        }
    }
}

struct EventDetailRSVPButton_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailRSVPButton(event: .constant(EVENTS[0]))
            .environmentObject(SessionStore())
    }
}
