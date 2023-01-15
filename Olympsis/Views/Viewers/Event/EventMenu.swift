//
//  EventMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct EventMenu: View {
    
    @State var event: Event
    @Binding var events: [Event]
    @StateObject private var observer = EventObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    func deleteEvent() async {
        let res = await observer.deleteEvent(id: event.id)
        if res {
            session.events.removeAll(where: {$0.id == event.id})
            events.removeAll(where: {$0.id == event.id})
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        VStack(alignment: .center){
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 5)
                .foregroundColor(.gray)
                .opacity(0.3)
                .padding(.bottom)
                .padding(.top, 5)
            Button(action:{}) {
                HStack {
                    Image(systemName: "exclamationmark.shield")
                        .imageScale(.large)
                        .padding(.leading)
                        .foregroundColor(.black)
                    Text("Report an Issue")
                        .foregroundColor(.black)
                    Spacer()
                }.modifier(MenuButton())
            }
            if let user = session.user {
                if user.uuid == event.ownerId {
                    Button(action:{
                        Task {
                            await deleteEvent()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                            HStack {
                                Image(systemName: "trash")
                                    .imageScale(.large)
                                    .padding(.leading)
                                    .foregroundColor(.red)
                                Text("Delete Event")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }.frame(width: SCREEN_WIDTH-25, height: 50)
                    }
                }
            }
            Spacer()
        }
    }
}

struct EventMenu_Previews: PreviewProvider {
    static var previews: some View {
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"])
        let _ = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "", isPrivate: false, members: [Member](), rules: ["No fighting"], createdAt: 0)
        let event = Event(id: "", ownerId: "", ownerData: peek, clubId: "", fieldId: "", imageURL: "soccer-0", title: "Pick Up Soccer", body: "Just come out and play boys.", sport: "soccer", level: 3, status: "pending", startTime: 0, maxParticipants: 0, participants: [Participant]())
        EventMenu(event: event, events: .constant([Event]())).environmentObject(SessionStore())
    }
}
