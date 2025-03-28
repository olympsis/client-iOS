//
//  EventParticipantsView.swift
//  Olympsis
//
//  This collection of views are in charge of showing the participants of an event
//  There is only one action. You can click on "See who's going..." to get more details about the participants
//
//  Created by Joel on 11/12/23.
//

import SwiftUI
import Charts

/// A view that shows a quick glance of the top participants in an event
struct EventParticipantsView: View {
    
    @Binding var clubs: [Club]
    @Binding var organizations: [Organization]
    
    @State private var showParticipants = false
    
    @EnvironmentObject private var event: Event
    
    
    /// An array of the event's participants
    /// If the array is less than 5 we will pad it with dummy participants so that the UI can look consistent
    var participants: [Participant] {
        return event.participants
    }
    
    var body: some View {
        HStack(spacing: -30) {
            ForEach(participants, id: \.self) { p in
                ParticipantView(participant: p)
            }
            Button(action: { self.showParticipants.toggle() }) {
                Text("See who's going...")
            }
            .padding(.leading, 45)
            .tint(Color.foreground)
        }.padding(.all)
            .sheet(isPresented: $showParticipants, content: {
                EventParticipantsViewExt(clubs: $clubs, organizations: $organizations)
                    .environmentObject(event)
            })
    }
}

// MARK: - RSVP CHART
/// A view that has simple chart about an event and the ratio of yes to maybe
struct EventRSVPChart: View {
    
    @EnvironmentObject private var event: Event
    
    var yesCount: Int {
        let yesNum = event.participants.filter { p in
            return p.status == EVENT_RSVP_STATUS.Yes
        }
        return yesNum.count
    }
    
    var maybeCount: Int {
        let maybeNum = event.participants .filter { p in
            return p.status == EVENT_RSVP_STATUS.Maybe
        }
        return maybeNum.count
    }
    
    var body: some View {
        Chart {
            BarMark(
                x: .value("Responses", "yes"),
                y: .value("Total Count", yesCount)
            ).foregroundStyle(Color("color-prime"))
            BarMark(
                x: .value("Responses", "Maybe"),
                y: .value("Total Count", maybeCount)
            ).foregroundStyle(Color("color-secnd"))
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

// MARK: - Participant View Extended
/// A view shows more information about the participants in an event
struct EventParticipantsViewExt: View {
    
    @Binding var clubs: [Club]
    @Binding var organizations: [Organization]
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var event: Event
    @Environment(SessionStore.self) private var session
    
    var participants: [Participant] {
        return event.participants
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
    
    func canRemoveParticipant(_ participant: Participant) -> Bool {
        guard let user = session.user,
              let uuid = user.uuid else {
            return false
        }
        return uuid != participant.user?.uuid && isPosterOrAdmin && event.getEventStatus() != EVENT_STATUS.ended
    }
    
    func removeParticipant(_ participant: Participant) async {
        guard await session.eventObserver.removeParticipant(id: event.id, pid: participant.id) else {
            return
        }
        event.participants.removeAll { $0.id == participant.id }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }.padding(.leading)
                Text("Participants")
                Spacer()
            }.padding(.vertical)
            
            EventRSVPChart()
                .environmentObject(event)
                .frame(height: 250)
            
            ForEach(participants, id: \.self) { p in
                HStack {
                    ParticipantView(participant: p)
                    Text(p.user?.username ?? "olympsis_user")
                    Spacer()
                    
                    if canRemoveParticipant(p) {
                        Menu {
                            Button(action: { Task { await removeParticipant(p) }}) {
                                Text("Remove Participant")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

#Preview {
    EventParticipantsView(clubs: .constant([]), organizations: .constant([]))
        .environment(SessionStore())
        .environmentObject(EVENTS[0])
}

#Preview {
    EventParticipantsViewExt(clubs: .constant([]), organizations: .constant([]))
        .environment(SessionStore())
        .environmentObject(EVENTS[0])
}
