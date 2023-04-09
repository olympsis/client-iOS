//
//  EventDetailActions.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventDetailActions: View {
    
    @Binding var event: Event
    @Binding var showMenu: Bool
    @State var user: UserStore
    @State var eventObserver: EventObserver
    
    var body: some View {
        ZStack {
            VStack {
                EventDetailRSVPButton(event: $event, user: user, eventObserver: eventObserver)
                if event.ownerId == user.uuid {
                    EventDetailActionButton(event: $event, showMenu: $showMenu, eventObserver: eventObserver)
                }
            }.padding(.all, 8)
            .background {
                Rectangle()
                    .cornerRadius(10)
                    .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
            }
        }.padding(.bottom, 50)
            .padding(.trailing)
    }
}

struct EventDetailActions_Previews: PreviewProvider {
    static var previews: some View {
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"])
        let participant = Participant(id: "", uuid: "", status: "going", data: UserPeek(firstName: "", lastName: "", username: "", imageURL: "", bio: "", sports: [""]), createdAt: 0)
        let event = Event(id: "", ownerId: "", ownerData: peek, clubId: "", fieldId: "", imageURL: "soccer-0", title: "Pick Up Soccer", body: "Just come out and play boys.", sport: "soccer", level: 3, status: "pending", startTime: 0, maxParticipants: 0, participants: [participant])
        let usr = UserStore(firstName: "", lastName: "", email: "", uuid: "", username: "", visibility: "private")
        EventDetailActions(event: .constant(event), showMenu: .constant(false), user: usr, eventObserver: EventObserver())
    }
}
