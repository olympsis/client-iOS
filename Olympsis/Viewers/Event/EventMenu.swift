//
//  EventMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct EventMenu: View {
    
    @Binding var event: Event
    @State private var loadingState: LOADING_STATE = .pending
    @State private var showNotification: Bool = false
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    
    func deleteEvent() async {
        guard let id = event.id else {
            return
        }
        let res = await session.eventObserver.deleteEvent(id: id)
        if res {
            await MainActor.run {
                session.events.removeAll(where: {$0.id == event.id})
                dismiss()
            }
        }
    }
    
    var isPosterOrAdmin: Bool {
        
        // check to see if you're the poster
        if let user = session.user,
           let uuid = user.uuid {
            if event.poster == uuid {
                return true
            }
        }
        
        if let data = event.data {
            // check to see if you're an admin of an associated club
            if let clubs = data.clubs {
                if let userClubs = session.user?.clubs {
                    let eventClubs = clubs.filter { c in
                        userClubs.contains { $0 == c.id }
                    }
                    guard let userID = session.user?.uuid else {
                        return false
                    }
                    return eventClubs.first { e in
                        e.members?.contains { ($0.uuid == userID) && ($0.role != MEMBER_ROLES.Member.rawValue) } ?? false
                    } != nil
                }
            }
            
            // check to see if you're an manager of an associated org
            if let organizations = data.organizations {
                if let userOrgs = session.user?.organizations {
                    let eventOrgs = organizations.filter { o in
                        userOrgs.contains { $0 == o.id }
                    }
                    guard let userID = session.user?.uuid else {
                        return false
                    }
                    return eventOrgs.first { e in
                        e.members?.contains { $0.uuid == userID } ?? false
                    } != nil
                }
            }
        }
        
        return true
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
                    event.actualStartTime = now
                    loadingState = .success
                }
            }
        }
    }
    
    func stopEvent() async {
        let status = "ended"
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(actualStopTime: now, status: status)
        loadingState = .loading
        guard let id = event.id else {
            return
        }
        let res = await session.eventObserver.updateEvent(id: id, dao: dao)
        if res {
            await MainActor.run {
                withAnimation(.easeInOut){
                    event.actualStopTime = now
                    loadingState = .success
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 15){
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 5)
                .foregroundColor(.gray)
                .opacity(0.3)
                .padding(.top, 5)
            
//                if isPosterOrAdmin {
//                    Menu {
//                        Button(action: { showNotification.toggle() }) {
//                            Text("Notify Participants")
//                        }
//                        Button(action: {}) {
//                            Text("Notify Club Members")
//                        }
//                    } label: {
//                        HStack {
//                            Image(systemName: "bell")
//                                .imageScale(.large)
//                                .padding(.leading)
//                                .foregroundColor(.black)
//                            Text("Send a Notification")
//                                .foregroundColor(.black)
//                            Spacer()
//                        }.modifier(MenuButton())
//                    }
//                }
            
            if isPosterOrAdmin {
                HStack(spacing: 15) {
                    if event.actualStopTime == nil {
                        Button(action:{
                            Task {
                                if event.actualStartTime == nil {
                                    await startEvent()
                                } else if event.actualStartTime != nil {
                                    await stopEvent()
                                }
                            }
                        }) {
                            VStack {
                                if event.actualStartTime == nil {
                                    if loadingState == .loading {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "play.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.green)
                                        Text("Start Event")
                                            .foregroundColor(.green)
                                    }
                                } else if event.actualStartTime != nil {
                                    if loadingState == .loading {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "stop.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.red)
                                        Text("Stop Event")
                                            .foregroundColor(.red)
                                    }
                                }
                            }.modifier(SettingButton())
                        }.disabled(loadingState == .loading ? true : false)
                            .frame(height: 100)
                    }
                    
                    Button(action:{
                        Task {
                            await deleteEvent()
                        }
                    }) {
                        VStack {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                            Text("Delete Event")
                                .foregroundColor(.red)
                        }.modifier(SettingButton())
                    }.frame(height: 100)
                }.padding(.horizontal)
            }
            
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
            Spacer()
        }.sheet(isPresented: $showNotification, content: {
            EventNotification(event: event)
        })
    }
}

#Preview {
    EventMenu(event: .constant(EVENTS[0]))
        .environmentObject(SessionStore())
}
