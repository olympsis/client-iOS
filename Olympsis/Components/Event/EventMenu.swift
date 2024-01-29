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
    @State private var showEditEvent: Bool = false
    
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
            if event.poster?.uuid == uuid {
                return true
            }
        }
        
        // check to see if you're an admin of an associated club
        if let clubs = event.clubs {
            if let userClubs = session.user?.clubs {
                let eventClubs = clubs.filter { c in
                    userClubs.contains { $0 == c.id }
                }
                guard let userID = session.user?.uuid else {
                    return false
                }
                return eventClubs.first { e in
                    e.members?.contains { ($0.user?.uuid == userID) && ($0.role != MEMBER_ROLES.Member.rawValue) } ?? false
                } != nil
            }
        }
        
        // check to see if you're an manager of an associated org
        if let organizations = event.organizations {
            if let userOrgs = session.user?.organizations {
                let eventOrgs = organizations.filter { o in
                    userOrgs.contains { $0 == o.id }
                }
                guard let userID = session.user?.uuid else {
                    return false
                }
                return eventOrgs.first { e in
                    e.members?.contains { $0.user?.uuid == userID } ?? false
                } != nil
            }
        }
        
        return true
    }
    
    func startEvent() async {
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(actualStopTime: now)
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
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(actualStopTime: now)
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
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 5)
                .foregroundColor(.gray)
                .opacity(0.3)
                .padding(.top, 5)
            
            if isPosterOrAdmin {
                MenuButton(icon: Image(systemName: "pencil"), text: "Edit Event", action:  {
                    self.showEditEvent.toggle()
                })
                
                if event.actualStopTime == nil {
                    HStack {
                        if event.actualStartTime == nil {
                            if loadingState == .loading {
                                ProgressView()
                            } else {
                                MenuButton(icon: Image(systemName: "play.fill"), text: "Start Event", action:  {
                                    Task {
                                        await startEvent()
                                    }
                                }, type: .start)
                            }
                        } else if event.actualStartTime != nil {
                            if loadingState == .loading {
                                ProgressView()
                            } else {
                                MenuButton(icon: Image(systemName: "square.fill"), text: "Stop Event", action:  {
                                    Task {
                                        await stopEvent()
                                    }
                                }, type: .destructive)
                            }
                        }
                    }.disabled(loadingState == .loading ? true : false)
                }
            }
            
            MenuButton(icon: Image(systemName: "exclamationmark.shield.fill"), text: "Report an Issue")
            
            if isPosterOrAdmin {
                MenuButton(icon: Image(systemName: "trash.fill"), text: "Remove Event", action: {
                    Task {
                        await deleteEvent()
                    }
                }, type: .destructive)
            }
            
            Spacer()
        }.sheet(isPresented: $showNotification, content: {
            EventNotification(event: event)
        })
        .fullScreenCover(isPresented: $showEditEvent, content: {
            if event.type == "pickup" {
                EditPickUpEvent(event: $event)
            } else {
                EditTournamentEvent(event: $event)
            }
        })
        
    }
}

#Preview {
    EventMenu(event: .constant(EVENTS[0]))
        .environmentObject(SessionStore())
}
