//
//  EventParticipantsView.swift
//  Olympsis
//
//  Created by Joel on 11/12/23.
//

import SwiftUI

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
