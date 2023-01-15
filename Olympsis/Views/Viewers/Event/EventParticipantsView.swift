//
//  EventParticipantsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventParticipantsView: View {
    @Binding var event: Event
    var body: some View {
        if let part = event.participants{
            if part.count > 0 {
                ScrollView(.horizontal ,showsIndicators: false){
                    HStack {
                        ForEach(part, id:\.id) { p in
                            ParticipantView(participant: p)
                        }
                    } .padding(.leading)
                }
            }
        }
    }
}

struct EventParticipantsView_Previews: PreviewProvider {
    static var previews: some View {
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"])
        let participant = Participant(id: "", uuid: "", status: "going", data: UserPeek(firstName: "", lastName: "", username: "", imageURL: "", bio: "", sports: [""]), createdAt: 0)
        let event = Event(id: "", ownerId: "", ownerData: peek, clubId: "", fieldId: "", imageURL: "soccer-0", title: "Pick Up Soccer", body: "Just come out and play boys.", sport: "soccer", level: 3, status: "in-progress", startTime: 0, maxParticipants: 0, participants: [participant])
        EventParticipantsView(event: .constant(event))
    }
}
