//
//  Messages.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct Messages: View {
    

    @Binding var club: Club
    @State var user: UserData
    @State var rooms = [Room]()
    @State private var text = ""
    @State private var showRooms = false
    @State private var showCancel = false
    @State private var showDetail = false
    @State private var showNewRoom = false
    
    @State private var state: LOADING_STATE = .pending
    
    @StateObject private var chatObserver = ChatObserver()
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    private var joinedRooms: [Room] {
        return rooms.filter({$0.members.contains(where: {$0.uuid == user.uuid})})
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if state == .loading {
                    ScrollView(showsIndicators: false) {
                        HStack {
                            SearchBar(text: $text, onCommit: {
                                showCancel = false
                            }).onTapGesture {
                                    if !showCancel {
                                        showCancel = true
                                    }
                                }
                            .frame(maxWidth: SCREEN_WIDTH-10, maxHeight: 40)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            if showCancel {
                                Button(action:{
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                    showCancel = false
                                }){
                                    Text("Cancel")
                                        .foregroundColor(.gray)
                                        .frame(maxHeight: 40)
                                }.padding(.trailing)
                            }
                        }.padding(.bottom, 5)
                        ForEach(1..<20, id: \.self) { number in
                            RoomTemplateView()
                                .padding(.bottom, 5)
                        }
                    }
                } else if state == .success{
                    if rooms.count > 0 {
                        ScrollView(showsIndicators: false) {
                            HStack {
                                SearchBar(text: $text, onCommit: {
                                    showCancel = false
                                }).onTapGesture {
                                        if !showCancel {
                                            showCancel = true
                                        }
                                    }
                                .frame(maxWidth: SCREEN_WIDTH-10, maxHeight: 40)
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                                if showCancel {
                                    Button(action:{
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                        showCancel = false
                                    }){
                                        Text("Cancel")
                                            .foregroundColor(.gray)
                                            .frame(maxHeight: 40)
                                    }.padding(.trailing)
                                }
                            }.padding(.bottom, 5)
                            ForEach(joinedRooms) { room in
                                Button(action:{ self.showDetail.toggle() }){
                                    RoomListView(room: room, rooms: $rooms, observer: chatObserver)
                                        .padding(.bottom)
                                }.fullScreenCover(isPresented: $showDetail) {
                                    RoomView(club: club, room: room, rooms: $rooms, observer: chatObserver)
                                }
                            }
                        }.refreshable {
                            let resp = await chatObserver.GetRooms(id: club.id!)
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
                            Text("Create one by pressing the + button")
                                .font(.caption)
                            Spacer()
                        }
                    }
                } else if state == .failure {
                    VStack {
                        Spacer()
                        Text("Failed to get chat rooms 😞")
                            .font(.caption)
                        Text("Please wait and try again")
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
                    Text("Messages")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{self.showNewRoom.toggle()}){
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{self.showRooms.toggle()}){
                        Image(systemName: "line.3.horizontal")
                            .imageScale(.large)
                    }
                }
            }
            .task {
                state = .loading
                let resp = await chatObserver.GetRooms(id: club.id!)
                if let r = resp {
                    await MainActor.run {
                        rooms = r.rooms
                        state = .success
                    }
                } else {
                    state = .success
                }
            }
            .fullScreenCover(isPresented: $showRooms) {
                RoomsSearch(club: $club, rooms: $rooms, observer: chatObserver)
                    .transition(.scale)
            }
            .fullScreenCover(isPresented: $showNewRoom) {
                NewRoom(club: $club, rooms: $rooms)
            }
        }
    }
}

struct Messages_Previews: PreviewProvider {
    static var previews: some View {
        let room = Room(id: "", name: "Admin's Chat", type: "Group", members: [ChatMember(id: "", uuid: "", status: "")], history: [Message]())
        Messages(club: .constant(CLUBS[0]), user: USERS_DATA[0], rooms: [room]).environmentObject(SessionStore())
    }
}
