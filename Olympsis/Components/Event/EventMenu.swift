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
//    @State private var showEditEvent: Bool = false
    @State private var showRecurring: Bool = false
    @State private var showNotification: Bool = false
    
    @EnvironmentObject private var event: Event
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    func deleteEvent(deleteAll: Bool = false) async {
        let res = await session.eventObserver.deleteEvent(id: event.id, deleteAll: deleteAll)
        if res {
            await MainActor.run {
                session.events.remove(event)
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
            e.members.contains { $0.user?.uuid == uuid }
        }) != nil {
            return true
        }
        
        return false
    }
    
    var body: some View {
        VStack {
            MenuButton(
                icon: Image(systemName: "exclamationmark.shield.fill"),
                text: "Report an Issue",
                action: { showReport.toggle() }
            )
            .padding(.top)
            
            
            if isPosterOrAdmin && event.getEventStatus() != EVENT_STATUS.ended {
                MenuButton(icon: Image(systemName: "trash.fill"), text: "Remove Event", action: {
                    if (event.recurrenceConfig != nil) {
                        Task {
                            await deleteEvent()
                        }
                    } else {
                        showRecurring.toggle()
                    }
                }, type: .destructive)
            }
            
            Spacer()
        }
        .presentationDragIndicator(.visible)
        .alert("Recurring Event", isPresented: $showRecurring, actions: {
            Button(role: .destructive) {
                Task {
                    await deleteEvent()
                }
            } label: {
                Text("Delete This")
            }
            
            Button(role: .destructive) {
                Task {
                    await deleteEvent(deleteAll: true)
                }
            } label: {
                Text("Delete All")
            }
        }, message: {
            Text("This event is part of a recurring event. Would you like to delete the individual event or the entire series?")
        })
        .sheet(isPresented: $showNotification, content: {
            EventNotification(event: event)
        })
        .fullScreenCover(isPresented: $showReport, content: {
            EventReportView(event: event)
        })
    }
}

#Preview {
    EventMenu(clubs: .constant(CLUBS), organizations: .constant(ORGANIZATIONS))
        .environmentObject(EVENTS[0])
        .environment(SessionStore())
}
