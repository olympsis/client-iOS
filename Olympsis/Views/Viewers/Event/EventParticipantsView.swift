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
    
    @Binding var event: Event
    @Binding var showParticipants: Bool
    
    /// An array of the event's participants
    /// If the array is less than 5 we will pad it with dummy participants so that the UI can look consistent
    var participants: [Participant] {
        guard var ptps = event.participants else {
            return [
                Participant(id: UUID().uuidString, uuid: UUID().uuidString, status: "going", createdAt: 0),
                Participant(id: UUID().uuidString, uuid: UUID().uuidString, status: "going", createdAt: 0),
                Participant(id: UUID().uuidString, uuid: UUID().uuidString, status: "going", createdAt: 0),
                Participant(id: UUID().uuidString, uuid: UUID().uuidString, status: "going", createdAt: 0)
            ]
        }
        if ptps.count < 5 {
            let remainder = 5 - ptps.count
            for _ in 1...remainder {
                ptps.append(Participant(id: UUID().uuidString, uuid: UUID().uuidString, status: "going", createdAt: 0))
            }
        } else {
            return ptps.dropLast(ptps.count - 5)
        }
        return ptps
    }
    
    var body: some View {
        HStack(spacing: -30) {
            ForEach(participants, id: \.self) { p in
                ParticipantView(participant: p)
            }
            Button(action: { self.showParticipants.toggle() }) {
                Text("See who's going...")
            }.padding(.leading, 45)
        }.padding(.all)
    }
}

// MARK: - RSVP CHART
/// A view that has simple chart about an event and the ratio of yes to maybe
struct EventRSVPChart: View {
    
    @Binding var event: Event
    
    var yesCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        let yesNum = participants.filter { p in
            return p.status == "yes"
        }
        return yesNum.count
    }
    
    var maybeCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        let maybeNum = participants.filter { p in
            return p.status == "maybe"
        }
        return maybeNum.count
    }
    
    var body: some View {
        if event.participants != nil {
            Chart {
                BarMark(
                    x: .value("Responses", "yes"),
                    y: .value("Total Count", yesCount)
                ).foregroundStyle(Color("color-prime"))
                BarMark(
                    x: .value("Responses", "Maybe"),
                    y: .value("Total Count", maybeCount)
                ).foregroundStyle(Color("color-secnd"))
            }.padding(.horizontal)
                .padding(.top)
        }
    }
}

// MARK: - Participant View Extended
/// A view shows more information about the participants in an event
struct EventParticipantsViewExt: View {
    
    @Binding var event: Event
    @Environment(\.presentationMode) private var presentationMode
    
    var participants: [Participant] {
        guard let ptps = event.participants else {
            return []
        }
        return ptps
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                }.padding(.leading)
                Text("Participants")
                Spacer()
            }.padding(.vertical)
            
            EventRSVPChart(event: $event)
                .frame(height: 250)
            
            ScrollView {
                ForEach(participants) { p in
                    HStack {
                        ParticipantView(participant: p)
                        Text(p.data?.username ?? "olympsis_user")
                        Spacer()
                    }.padding(.horizontal)
                }
            }.scrollIndicators(.hidden)
        }
    }
}

#Preview {
    EventParticipantsView(event: .constant(EVENTS[0]), showParticipants: .constant(false))
}

#Preview {
    EventParticipantsViewExt(event: .constant(EVENTS[0]))
}
