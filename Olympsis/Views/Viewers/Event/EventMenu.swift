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
        guard let id = event.id else {
            return
        }
        let res = await observer.deleteEvent(id: id)
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
//            if let user = session.user {
//                if user.uuid == event.poster {
//                    Button(action:{
//                        Task {
//                            await deleteEvent()
//                        }
//                    }) {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 10)
//                                .foregroundColor(.gray)
//                                .opacity(0.3)
//                            HStack {
//                                Image(systemName: "trash")
//                                    .imageScale(.large)
//                                    .padding(.leading)
//                                    .foregroundColor(.red)
//                                Text("Delete Event")
//                                    .foregroundColor(.red)
//                                Spacer()
//                            }
//                        }.frame(width: SCREEN_WIDTH-25, height: 50)
//                    }
//                }
//            }
            Spacer()
        }
    }
}

struct EventMenu_Previews: PreviewProvider {
    static var previews: some View {
        EventMenu(event: EVENTS[0], events: .constant([Event]())).environmentObject(SessionStore())
    }
}
