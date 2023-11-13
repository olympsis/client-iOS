//
//  EventMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct EventMenu: View {
    
    @Binding var event: Event
    @State var loadingState: LOADING_STATE = .pending
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    func deleteEvent() async {
        guard let id = event.id else {
            return
        }
        let res = await session.eventObserver.deleteEvent(id: id)
        if res {
            await MainActor.run {
                session.events.removeAll(where: {$0.id == event.id})
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    var isPosterOrAdmin: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let eventPoster = event.poster,
              let club = session.clubs.first(where: { $0.id == event.clubID }),
              let members = club.members else {
            return false
        }
        
        guard let member = members.first(where: { $0.uuid == uuid }) else {
            return false
        }
        
        if member.role != "member" {
            return true
        }
        
        return (eventPoster == uuid)
    }
    
    func startEvent() async {
        let status = "in-progress"
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(actualSTime: now, status: status)
        loadingState = .loading
        guard let id = event.id else {
            return
        }
        let res = await session.eventObserver.updateEvent(id: id, dao: dao)
        if res {
            await MainActor.run {
                withAnimation(.easeInOut){
                    event.actualStartTime = Int64(now)
                    loadingState = .success
                }
            }
        }
    }
    
    func stopEvent() async {
        let status = "ended"
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(stopTime: now, status: status)
        loadingState = .loading
        guard let id = event.id else {
            return
        }
        let res = await session.eventObserver.updateEvent(id: id, dao: dao)
        if res {
            await MainActor.run {
                withAnimation(.easeInOut){
                    event.stopTime = Int64(now)
                    loadingState = .success
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .center){
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 5)
                .foregroundColor(.gray)
                .opacity(0.3)
                .padding(.top, 5)
            Button(action:{}) {
                HStack {
                    Image(systemName: "exclamationmark.shield")
                        .imageScale(.large)
                        .padding(.leading)
                        .foregroundColor(.black)
                    Text("Report an Issue")
                        .foregroundColor(.black)
                    Spacer()
                }.modifier(MenuButton())
            }
            
            if isPosterOrAdmin {
                
                if event.stopTime == nil {
                    Button(action:{
                        Task {
                            if event.actualStartTime == nil {
                                await startEvent()
                            } else if event.actualStartTime != nil {
                                await stopEvent()
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                            HStack {
                                if event.actualStartTime == nil {
                                    Image(systemName: "play.fill")
                                        .imageScale(.large)
                                        .padding(.leading)
                                        .foregroundColor(.green)
                                    Text("Start Event")
                                        .foregroundColor(.green)
                                } else if event.actualStartTime != nil {
                                    Image(systemName: "stop.fill")
                                        .padding(.leading)
                                        .imageScale(.large)
                                        .foregroundColor(.red)
                                    Text("Stop Event")
                                        .foregroundColor(.red)
                                    if loadingState == .loading {
                                        ProgressView()
                                    }
                                }
                                
                                Spacer()
                            }
                        }.frame(width: SCREEN_WIDTH-25, height: 50)
                    }.disabled(loadingState == .loading ? true : false)
                }
                
                Button(action:{
                    Task {
                        await deleteEvent()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.gray)
                            .opacity(0.3)
                        HStack {
                            Image(systemName: "trash")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.red)
                            Text("Delete Event")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }.frame(width: SCREEN_WIDTH-25, height: 50)
                }
            }
            
            
            
            Spacer()
        }
    }
}

#Preview {
    EventMenu(event: .constant(EVENTS[0]))
        .environmentObject(SessionStore())
}
