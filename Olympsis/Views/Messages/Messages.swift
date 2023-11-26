//
//  Messages.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct Messages: View {
    
    @State var club: Club
    @State var rooms = [Room]()
    @State private var text = ""
    @State private var selectedView = 0
    @State private var showRooms = false
    @State private var showCancel = false
    @State private var showDetail = false
    @State private var showNewRoom = false
    
    @State private var state: LOADING_STATE = .pending
    
    @StateObject private var chatObserver = ChatObserver()
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var notificationManager: NotificationsManager
    
    private var joinedRooms: [Room] {
        guard let user = session.user,
              let uuid = user.uuid else {
            return rooms //[Room]()
        }
        return rooms.filter({$0.members.contains(where: {$0.uuid == uuid })})
    }
    
    private var notJoinedRooms: [Room] {
        guard let user = session.user,
              let uuid = user.uuid else {
            return [Room]()
        }
        return rooms.filter({ !($0.members.contains(where: { $0.uuid == uuid })) })
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if state == .loading {
                    ProgressView()
                } else if state == .failure {
                    Text("Failed to load messages")
                } else {
                    HStack {
                        Spacer()
                        Button(action: { selectedView = 0 }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(selectedView == 0 ? Color("color-prime") : Color("color-secnd"))
                                
                                Text("Joined")
                                    .foregroundColor(.white)
                            }.padding(.horizontal)
                                .frame(height: 35)
                        }
                        Spacer()
                        Rectangle()
                            .frame(width: 1, height: 35)
                        Spacer()
                        Button(action: { selectedView = 1 }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(selectedView == 1 ? Color("color-prime") : Color("color-secnd"))
                                
                                
                                Text("Not Joined")
                                    .foregroundColor(.white)
                            }.padding(.horizontal)
                                .frame(height: 35)
                        }
                        Spacer()
                    }.padding(.top)
                    
                    TabView(selection: $selectedView) {
                        ScrollView() {
                            ForEach(joinedRooms) { room in
                                Button(action:{ self.showDetail.toggle() }){
                                    RoomListView(room: room, rooms: $rooms, observer: chatObserver)
                                        .padding(.bottom)
                                }.fullScreenCover(isPresented: $showDetail) {
                                    RoomView(club: club, room: room, rooms: $rooms, observer: chatObserver)
                                }
                            }
                        }.tabItem {
                            Text("Joined")
                        }
                        .tag(0)
                        
                        ScrollView() {
                            ForEach(notJoinedRooms) { room in
                                Button(action:{ self.showDetail.toggle() }){
                                    RoomListView(room: room, rooms: $rooms, observer: chatObserver)
                                        .padding(.bottom)
                                }.fullScreenCover(isPresented: $showDetail) {
                                    RoomView(club: club, room: room, rooms: $rooms, observer: chatObserver)
                                }
                            }
                        }.tabItem {
                            Text("Not Joined")
                        }
                        .tag(1)
                    }.tabViewStyle(.page)
                        .padding(.top)
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
                        Image(systemName: "plus.square.dashed")
                            .imageScale(.large)
                    }
                }
            }
            .task {
                notificationManager.inMessageView = true
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
            .onDisappear {
                notificationManager.inMessageView = false
            }
            .fullScreenCover(isPresented: $showNewRoom) {
                NewRoom(club: $club, rooms: $rooms)
            }
            .tint(Color("color-prime"))
        }
    }
}

struct Messages_Previews: PreviewProvider {
    static var previews: some View {
        let room = Room(id: "", name: "Admin's Chat", type: "Group", members: [ChatMember(id: "", uuid: "", status: "")], history: [Message]())
        Messages(club: CLUBS[0], rooms: [room]).environmentObject(SessionStore()).environmentObject(NotificationsManager())
    }
}
