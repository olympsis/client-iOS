//
//  RoomsSearch.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/7/23.
//

import SwiftUI

struct RoomsSearch: View {
    
    @Binding var club: Club
    @Binding var rooms: [Room]
    @State var observer: ChatObserver
    @State private var state: LOADING_STATE = .success
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if rooms.count > 0 {
                        ScrollView(showsIndicators: false) {
                            ForEach(rooms) { room in
                                RoomListView(room: room, rooms: $rooms, observer: observer)
                                    .padding(.top)
                            }
                        }.refreshable {
                            let resp = await observer.GetRooms(id: club.id!)
                            await MainActor.run {
                                if let r = resp {
                                    self.rooms = r.rooms
                                }
                            }
                        }
                    } else {
                        VStack {
                            Spacer()
                            Text("There are no chat rooms 😞")
                                .font(.caption)
                            Text("Go to the previous page and create one.")
                                .font(.caption)
                            Spacer()
                        }
                    }
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                            Image(systemName: "chevron.left")
                                .imageScale(.large)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Chat Rooms")
                    }
                }
            }.refreshable {
                state = .loading
                let resp = await observer.GetRooms(id: club.id!)
                if let r = resp {
                    await MainActor.run {
                        rooms = r.rooms
                    }
                }
                state = .success
            }
        }
    }
}

struct RoomsSearch_Previews: PreviewProvider {
    static var previews: some View {
        let room = Room(id: "", name: "Admin's Chat", type: "Group", group: GroupModel(id: UUID().uuidString, type: "club"), members: [ChatMember](), history: [Message]())
        RoomsSearch(club: .constant(CLUBS[0]), rooms:.constant([room]), observer: ChatObserver())
            .environmentObject(SessionStore())
    }
}
