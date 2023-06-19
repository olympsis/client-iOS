//
//  EventDetailMiddleView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/18/22.
//

import SwiftUI

struct EventDetailMiddleView: View {
    
    @Binding var event: Event
    @State var showMenu: Bool
    @State private var isBlinking = false
    @State private var timeDifference = 0
    @State private var state: LOADING_STATE = .pending
    
    @EnvironmentObject var session: SessionStore
    
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
        event = update
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
        event = update
        state = .success
    }
    
    func getTimeDifference() -> Int {
        guard let startTime = event.actualStartTime else {
            return 2
        }
        let startDate = Date(timeIntervalSince1970: TimeInterval(startTime))
        let time = Calendar.current.dateComponents([.minute], from: startDate, to: Date.now)
        if let min = time.minute {
            return min
        }
        return 1
    }
    
    var startTime: Int64 {
        guard let time = event.startTime else {
            return 0
        }
        return time
    }
    
    var eventEnded: Bool {
        return event.status == "ended"
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
        HStack (alignment: .center){
            VStack(alignment: .center){
                if event.status == "in-progress" {
                    HStack {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.red)
                        Text("Live")
                            .bold()
                        .foregroundColor(.red)
                        
                    }
                    Text("\(timeDifference) mins")
                        .foregroundColor(.primary)
                        .bold()
                        .onAppear {
                            timeDifference = getTimeDifference()
                            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { t in
                                timeDifference = getTimeDifference()
                            }
                        }
                } else if event.status == "pending"{
                    VStack {
                        Text("Pending")
                            .foregroundColor(Color("primary-color"))
                        Text(Date(timeIntervalSince1970: TimeInterval(startTime)).formatted(.dateTime.hour().minute()))
                            .foregroundColor(.green)
                            .bold()
                    }
                } else if event.status == "ended" {
                    VStack {
                        Text("Ended")
                            .foregroundColor(.gray)
                            .bold()
                        if let sT = event.stopTime {
                            Text(Date(timeIntervalSince1970: TimeInterval(sT)).formatted(.dateTime.hour().minute()))
                                .foregroundColor(.primary)
                                .bold()
                        }
                    }
                }
            }.frame(width: 120)
                .padding(.all, 7)
                

            VStack {
                VStack {
                    if event.status == "pending" {
                        if !hasResponded {
                            Menu {
                                Button(action: { Task{  await rsvp(status: "no") } }) {
                                    Text("No")
                                }
                                Button(action: { Task{  await rsvp(status: "maybe") } }) {
                                    Text("Maybe")
                                }
                                Button(action:{ Task { await rsvp(status: "yes") } }){
                                    Text("I'm In")
                                }
                            } label: {
                                ZStack {
                                    Image(systemName: "envelope")
                                        .imageScale(.large)
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
                                        .imageScale(.large)
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
                    .opacity(event.status == "ended" ? 0 : 1)
                .disabled(eventEnded)
            }.frame(width: 100)
            
            VStack(alignment: .center){
                switch(event.level){
                case 1:
                    Circle()
                        .frame(width: 10)
                        .imageScale(.small)
                    .foregroundColor(Color("tertiary-color"))
                case 2:
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("tertiary-color"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("tertiary-color"))
                    }
                case 3:
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("tertiary-color"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("tertiary-color"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("tertiary-color"))
                    }
                default:
                    Circle()
                        .frame(width: 10)
                        .imageScale(.small)
                        .foregroundColor(Color("tertiary-color"))
                }
                
                Text("level")
                    .foregroundColor(.primary)
                    .bold()
            }
                .padding(.all, 7)
                .frame(width: 120)
                
        }.frame(width: SCREEN_WIDTH - 25)
            .border(Color.primary, width: 1)
    }
}

struct EventDetailMiddleView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailMiddleView(event: .constant(EVENTS[0]), showMenu: false).environmentObject(SessionStore())
    }
}
