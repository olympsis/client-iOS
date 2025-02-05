//
//  EventMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct EventMenu: View {
    
    @Binding var clubs: [Club]
    @Binding var organizations: [Organization]
    
    @State private var loadingState: LOADING_STATE = .pending
    @State private var showReport: Bool = false
    @State private var showEditEvent: Bool = false
    @State private var showNotification: Bool = false
    
    @EnvironmentObject private var event: Event
    @Environment(SessionStore.self) private var session
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
        guard let user = session.user,
           let uuid = user.uuid else {
            return false
        }
        
        if event.poster?.uuid == uuid {
            return true
        }
        
        if clubs.first(where: { e in
            e.members.contains { ($0.user?.uuid == uuid) && ($0.role != MEMBER_ROLES.Member.rawValue) }
        }) != nil {
            return true
        }
        
        
        if organizations.first(where: { e in
            e.members?.contains { $0.user?.uuid == uuid } ?? false
        }) != nil {
            return true
        }
        
        return false
    }
    
    func startEvent() async {
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(actualStartTime: now)
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
            Group {
                if isPosterOrAdmin {
    // TODO: - Disabling for now
    //                MenuButton(icon: Image(systemName: "pencil"), text: "Edit Event", action:  {
    //                    self.showEditEvent.toggle()
    //                })
                    
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
                
                MenuButton(icon: Image(systemName: "exclamationmark.shield.fill"), text: "Report an Issue", action: { showReport.toggle() })
                
                
                if isPosterOrAdmin {
                    MenuButton(icon: Image(systemName: "trash.fill"), text: "Remove Event", action: {
                        Task {
                            await deleteEvent()
                        }
                    }, type: .destructive)
                }
            }.padding(.top)
            
            Spacer()
        }
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showNotification, content: {
            EventNotification(event: event)
        })
        .fullScreenCover(isPresented: $showReport, content: {
            EventReportView(event: event)
        })
        .fullScreenCover(isPresented: $showEditEvent, content: {
            if event.type == EVENT_TYPES.PickUp {
                EditPickUpEvent()
                    .environmentObject(event)
            } else {
                EditTournamentEvent()
                    .environmentObject(event)
            }
        })
        
    }
}

#Preview {
    EventMenu(clubs: .constant(CLUBS), organizations: .constant(ORGANIZATIONS))
        .environmentObject(EVENTS[0])
        .environment(SessionStore())
}
