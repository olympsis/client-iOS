//
//  EventDetailTopActionButtons.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventDetailActionButton: View {
    
    @Binding var event: Event
    @Binding var showMenu: Bool
    @State private var state: LOADING_STATE = .pending
    @Environment(\.isPresented) var isPresented
    
    @State var eventObserver: EventObserver
    
    func startEvent() async {
        let status = "in-progress"
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(actualSTime: now, status: status)
        state = .loading
        let res = await eventObserver.updateEvent(id: event.id, dao: dao)
        if res {
            await MainActor.run {
                withAnimation(.easeInOut){
                    event.actualStartTime = now
                    event.status = status
                    state = .success
                }
            }
        }
    }
    
    func stopEvent() async {
        let status = "ended"
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(stopTime: now, status: status)
        state = .loading
        let res = await eventObserver.updateEvent(id: event.id, dao: dao)
        if res {
            await MainActor.run {
                withAnimation(.easeInOut){
                    event.stopTime = now
                    event.status = status
                    state = .success
                }
            }
        }
    }
    
    var body: some View {
        HStack {
            if event.status == "pending" {
                Button(action:{ Task { await startEvent() } }){
                    ZStack {
                        Image(systemName: "play.fill")
                            .resizable()
                            .foregroundColor(.green)
                        .frame(width: 40, height: 40)
                        if state == .loading {
                            ProgressView()
                        }
                    }
                }.disabled(state == .loading ? true : false)
            } else if event.status == "in-progress" {
                Button(action:{ Task { await stopEvent() } }){
                    ZStack {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .foregroundColor(.red)
                        .frame(width: 40, height: 40)
                        if state == .loading {
                            ProgressView()
                        }
                    }
                }.disabled(state == .loading ? true : false)
            }
        }
    }
}

struct EventDetailActionButton_Previews: PreviewProvider {
    static var previews: some View {
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"])
        let participant = Participant(id: "", uuid: "", status: "going", data: UserPeek(firstName: "", lastName: "", username: "", imageURL: "", bio: "", sports: [""]), createdAt: 0)
        let event = Event(id: "", ownerId: "", ownerData: peek, clubId: "", fieldId: "", imageURL: "soccer-0", title: "Pick Up Soccer", body: "Just come out and play boys.", sport: "soccer", level: 3, status: "in-progress", startTime: 0, maxParticipants: 0, participants: [participant])
        EventDetailActionButton(event: .constant(event), showMenu: .constant(false), eventObserver: EventObserver())
    }
}
