//
//  EventMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct EventMenu: View {
    
    @Binding var event: Event
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    func deleteEvent() async {
        guard let id = event.id else {
            return
        }
        let res = await session.eventObserver.deleteEvent(id: id)
        if res {
            await MainActor.run {
                session.events.removeAll(where: {$0.id == event.id})
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    var isPosterOrAdmin: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let eventPoster = event.poster,
              let club = session.clubs.first(where: { $0.id == event.clubID }),
              let members = club.members else {
            return false
        }
        
        guard let member = members.first(where: { $0.uuid == uuid }),
              member.role != "member" else {
            return false
        }
        
        return (eventPoster == uuid)
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
            
            if isPosterOrAdmin {
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
            
            Spacer()
        }
    }
}

struct EventMenu_Previews: PreviewProvider {
    static var previews: some View {
        EventMenu(event: .constant(EVENTS[0])).environmentObject(SessionStore())
    }
}
