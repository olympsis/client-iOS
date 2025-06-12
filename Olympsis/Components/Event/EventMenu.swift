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
                text: String(localized: "event-menu-issue", table: "Events"),
                action: { showReport.toggle() }
            )
            .padding(.top)
            
            
            if isPosterOrAdmin && event.getEventStatus() != EVENT_STATUS.ended {
                MenuButton(icon: Image(systemName: "trash.fill"), text: "Remove Event", action: {
                    guard event.recurrenceConfig == nil else {
                        showRecurring.toggle()
                        return
                    }
                    Task {
                        await deleteEvent()
                    }
                }, type: .destructive)
            }
            
            Spacer()
        }
        .presentationDragIndicator(.visible)
        .alert(String(localized: "advanced-settings-recurring", table: "Events"), isPresented: $showRecurring, actions: {
            Button(role: .destructive) {
                Task {
                    await deleteEvent()
                }
            } label: {
                Text(String(localized: "event-delete-recurring-warning-title1", table: "Events"))
            }
            
            Button(role: .destructive) {
                Task {
                    await deleteEvent(deleteAll: true)
                }
            } label: {
                Text(String(localized: "event-delete-recurring-warning-title2", table: "Events"))
            }
        }, message: {
            Text(String(localized: "event-delete-recurring-warning-sub-title", table: "Events"))
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
