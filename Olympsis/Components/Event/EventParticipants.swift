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
struct EventParticipants: View {
    
    @Binding var clubs: [Club]
    @Binding var organizations: [Organization]
    
    @State private var showParticipants = false
    
    @Environment(Event.self) private var event: Event
    @Environment(SessionStore.self) private var session: SessionStore
    
    /// Compute wether or not we can allow the users to see the participants list
    /// If hide participants is set to true then we only show the participants when the user has RSVPed
    private var canShowParticipants: Bool {
        guard let config = event.participantsConfig,
              let hideParticipants = config.hideParticipants else {
            return true
        }
        
        // Reveal after user has RSVPed
        guard let user = session.user,
              let userID = user.userID,
              event.rsvp(for: userID) != nil else {
            return !hideParticipants
        }
        return true
    }
    
    /// An array of the event's participants
    /// If the array is less than 5 we will pad it with dummy participants so that the UI can look consistent
    private var participants: [Participant] {
        return event.participants
    }
    
    /// Convert the participants status and return it's string
    private var participantsStatus: String {
        switch event.getEventStatus() {
        case .ended:
            return String(localized: "participants-status-attended", table: "Events")
        case .live:
            return String(localized: "participants-status-attending", table: "Events")
        case .pending:
            return String(localized: "participants-status-going", table: "Events")
        }
    }
    
    /// If you are the poster or admin there is a lot more you can see and do
    private var isPosterOrAdmin: Bool {
        
        // check to see if you're the poster
        guard let user = session.user,
           let userID = user.userID else {
            return false
        }
        
        if event.poster?.userID == userID {
            return true
        }
        
        if clubs.first(where: { e in
            e.members.contains { ($0.user?.userID == userID) && ($0.role != MEMBER_ROLES.Member.rawValue) }
        }) != nil {
            return true
        }
        
        
        if organizations.first(where: { e in
            e.members.contains { $0.user?.userID == userID }
        }) != nil {
            return true
        }
        
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(event.participants.count) \(participantsStatus)")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(event.participants.prefix(3), id: \.id) { ptp in
                ParticipantView(participant: ptp, posterOrAdminViewing: isPosterOrAdmin)
                    .environment(session)
            }.redacted(reason: canShowParticipants ? [] : .placeholder)
            
            if (event.participants.count > 3 && canShowParticipants) {
                Button(action: { showParticipants.toggle() }) {
                    Text("+\(event.participants.count-3) \(String(localized: "more", table: "General"))...")
                        .font(.callout)
                        .fontWeight(.medium)
                }.padding(.top)
            }
        }
        .padding(.all)
        .sheet(isPresented: $showParticipants, content: {
            EventParticipantsViewExt(clubs: $clubs, organizations: $organizations)
                .environment(event)
                .presentationDragIndicator(.visible)
        })
    }
}

// MARK: - RSVP CHART
/// A view that has simple chart about an event and the ratio of yes to maybe
struct EventRSVPChart: View {
    
    @Environment(Event.self) private var event: Event
    
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
                x: .value("Responses", "I'm in!"),
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
    @Environment(Event.self) private var event: Event
    @Environment(SessionStore.self) private var session
    
    var participants: [Participant] {
        return event.participants
    }
    
    var isPosterOrAdmin: Bool {
        
        // check to see if you're the poster
        guard let user = session.user,
           let userID = user.userID else {
            return false
        }
        
        if event.poster?.userID == userID {
            return true
        }
        
        if clubs.first(where: { e in
            e.members.contains { ($0.user?.userID == userID) && ($0.role != MEMBER_ROLES.Member.rawValue) }
        }) != nil {
            return true
        }
        
        
        if organizations.first(where: { e in
            e.members.contains { $0.user?.userID == userID }
        }) != nil {
            return true
        }
        
        return false
    }
    
    func canRemoveParticipant(_ participant: Participant) -> Bool {
        guard let user = session.user,
              let userID = user.userID else {
            return false
        }
        return userID != participant.user?.userID && isPosterOrAdmin && event.getEventStatus() != EVENT_STATUS.ended
    }
    
    func removeParticipant(_ participant: Participant) async {
        guard await session.eventService.removeParticipant(id: event.id, pid: participant.id) else {
            return
        }
        event.participants.removeAll { $0.id == participant.id }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "event-participants", table: "Events"))
                .font(.headline)
                .padding([.leading, .top])
            
            EventRSVPChart()
                .environment(event)
                .frame(height: 250)
            
            ForEach(participants, id: \.self) { p in
                HStack {
                    ParticipantView(participant: p, posterOrAdminViewing: isPosterOrAdmin)
                        .environment(event)
                        .environment(session)
                    Spacer()
                    
                    if canRemoveParticipant(p) {
                        Menu {
                            Button(action: { Task { await removeParticipant(p) }}) {
                                Text(String(localized: "event-remove-participant", table: "Events"))
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
    EventParticipants(clubs: .constant([]), organizations: .constant([]))
        .environment(EVENTS[0])
        .environment(SessionStore())
}

#Preview {
    EventParticipantsViewExt(clubs: .constant([]), organizations: .constant([]))
        .environment(SessionStore())
        .environment(EVENTS[0])
}
