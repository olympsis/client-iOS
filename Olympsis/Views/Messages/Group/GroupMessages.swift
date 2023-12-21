//
//  GroupMessages.swift
//  Olympsis
//
//  Created by Joel on 12/20/23.
//

import SwiftUI

struct GroupMessages: View {
    
    @State var org: Organization
    @State var rooms = [Room]()
    @State private var selectedView = 0
    @State private var showRooms = false
    @State private var showCancel = false
    @State private var showDetail = false
    @State private var selectedRoom: Room?
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
                                if selectedView == 0 {
                                    Rectangle()
                                        .foregroundColor(Color("color-prime"))
                                    Text("Joined")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .textCase(.uppercase)
                                } else {
                                    Rectangle()
                                        .stroke(lineWidth: 1)
                                    Text("Joined")
                                        .foregroundColor(.primary)
                                        .font(.caption)
                                        .textCase(.uppercase)
                                }
                            }.padding(.horizontal)
                                .frame(height: 35)
                        }
                        Spacer()
                        Rectangle()
                            .frame(width: 1, height: 35)
                        Spacer()
                        Button(action: { selectedView = 1 }) {
                            ZStack {
                                if selectedView == 1 {
                                    Rectangle().foregroundStyle(Color("color-prime"))
                                    Text("All Chats")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .textCase(.uppercase)
                                } else {
                                    Rectangle().stroke(lineWidth: 1)
                                    Text("All Chats")
                                        .foregroundColor(.primary)
                                        .font(.caption)
                                        .textCase(.uppercase)
                                }
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
                                        .onTapGesture {
                                            selectedRoom = room
                                        }
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
                                    GroupRoomView(org: org, room: room, rooms: $rooms, observer: chatObserver)
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
                let resp = await chatObserver.GetRooms(id: org.id!)
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
                GroupNewRoom(org: $org, rooms: $rooms)
            }
            .fullScreenCover(item: $selectedRoom, content: { r in
                GroupRoomView(org: org, room: r, rooms: $rooms, observer: chatObserver)
            })
            .tint(Color("color-prime"))
        }
    }
}

#Preview {
    GroupMessages(org: ORGANIZATIONS[0], rooms: ROOMS)
        .environmentObject(SessionStore())
        .environmentObject(NotificationsManager())
}
