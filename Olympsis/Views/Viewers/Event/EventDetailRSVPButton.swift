//
//  EventDetailRSVPActions.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventDetailRSVPButton: View {
    
    @Binding var event: Event
    @State var user: UserStore
    @State var eventObserver: EventObserver
    @State private var state: LOADING_STATE = .pending
    
    func rsvp(status: String) async {
        state = .loading
        let dao = ParticipantDao(_uuid: user.uuid, _status: status)
        let _ = await eventObserver.addParticipant(id: event.id, dao: dao)
        if let img = user.imageURL {
            let p = Participant(id: UUID().uuidString, uuid: user.uuid, status: status, data: UserPeek(firstName: "", lastName: "", username: "", imageURL: img, bio: "", sports: [""]), createdAt: 0)
            withAnimation(.spring()){
                if event.participants != nil {
                    event.participants!.append(p)
                } else {
                    event.participants = [p]
                }
            }
        } else {
            let p = Participant(id: UUID().uuidString, uuid: user.uuid, status: status, data: UserPeek(firstName: "", lastName: "", username: "", imageURL: "", bio: "", sports: [""]), createdAt: 0)
            withAnimation(.spring()){
                if event.participants != nil {
                    event.participants!.append(p)
                } else {
                    event.participants = [p]
                }
            }
        }
        state = .success
    }
    
    func cancel() async {
        state = .loading
        if let pid = event.participants?.first(where: {$0.uuid == user.uuid}){
            let res = await eventObserver.removeParticipant(id: event.id, pid: pid.id)
            if res {
                withAnimation(.easeOut) {
                    event.participants?.removeAll(where: {$0.uuid == user.uuid})
                }
            }
        }
        state = .success
    }
    
    var body: some View {
        VStack {
            if event.status == "pending" {
                if (event.participants?.first(where: {$0.uuid == user.uuid})) == nil {
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
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"])
        let participant = Participant(id: "", uuid: "", status: "going", data: UserPeek(firstName: "", lastName: "", username: "", imageURL: "", bio: "", sports: [""]), createdAt: 0)
        let event = Event(id: "", ownerId: "", ownerData: peek, clubId: "", fieldId: "", imageURL: "soccer-0", title: "Pick Up Soccer", body: "Just come out and play boys.", sport: "soccer", level: 3, status: "pending", startTime: 0, maxParticipants: 0, participants: [participant])
        let usr = UserStore(firstName: "", lastName: "", email: "", uuid: "", username: "", isPublic: false)
        EventDetailRSVPButton(event: .constant(event), user: usr, eventObserver: EventObserver())
            .environmentObject(SessionStore())
    }
}
