//
//  GroupMessages.swift
//  Olympsis
//
//  Created by Joel on 12/20/23.
//

import os
import SwiftUI

struct GroupMessages: View {
    
    @State var rooms = [Room]()
    @State private var selectedView = 0
    @State private var showRooms = false
    @State private var showCancel = false
    @State private var showDetail = false
    @State private var selectedRoom: Room?
    @State private var showNewRoom = false
    @State private var state: LOADING_STATE = .success

    @StateObject private var chatObserver = ChatObserver()
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    
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
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "group_messages_view")
    
    @MainActor
    func fetchChatRooms() async {
        state = .loading
        guard let selectedGroup = session.selectedGroup else {
            log.error("Failed to find the selected group!")
            state = .failure
            return
        }
        
        if selectedGroup.type == .Club {
            guard let id = selectedGroup.club?.id,
                let resp = await chatObserver.GetRooms(id: id) else {
                log.info("No chat rooms found")
                state = .success
                return
            }
            rooms = resp.rooms
            state = .success
        } else {
            guard let id = selectedGroup.organization?.id,
                let resp = await chatObserver.GetRooms(id: id) else {
                log.info("No chat rooms found")
                state = .success
                return
            }
            rooms = resp.rooms
            state = .success
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                switch state {
                case .loading:
                    ScrollView {
                        ForEach(0..<15, id: \.self){ _ in
                            RoomListItemTemplate()
                        }
                    }
                case .success, .pending:
                    HStack {
                        Spacer()
                        Button(action: { selectedView = 0 }) {
                            ZStack {
                                if selectedView == 0 {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color.colorPrime)
                                    Text("Joined")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .textCase(.uppercase)
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 1)
                                    Text("Joined")
                                        .foregroundColor(Color.foreground)
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
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color.colorPrime)
                                    Text("Not Joined")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .textCase(.uppercase)
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 1)
                                    Text("Not Joined")
                                        .foregroundColor(Color.foreground)
                                        .font(.caption)
                                        .textCase(.uppercase)
                                }
                            }
                            .padding(.horizontal)
                            .frame(height: 35)
                        }
                        Spacer()
                    }.padding(.top)
                    
                    TabView(selection: $selectedView) {
                        ScrollView() {
                            if joinedRooms.count == 0 {
                                Rectangle()
                                    .frame(height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal)
                                    .foregroundStyle(Color.background)
                                    .overlay {
                                        VStack {
                                            Text("No rooms found")
                                                .foregroundStyle(Color.foreground)
                                            
                                            Button(action: { selectedView = 1 }) {
                                                Text("Check Rooms")
                                                    .font(.callout)
                                                    .padding(.vertical, 5)
                                            }
                                        }
                                    }
                            } else {
                                ForEach(joinedRooms) { room in
                                    Button(action:{ self.showDetail.toggle() }){
                                        RoomListItem(room: room, rooms: $rooms, observer: chatObserver)
                                            .padding(.bottom)
                                            .onTapGesture {
                                                selectedRoom = room
                                            }
                                    }
                                }
                            }
                        }
                        .refreshable {
                            await fetchChatRooms()
                        }
                        .tabItem {
                            Text("Joined")
                        }
                        .tag(0)

                        
                        ScrollView() {
                            if notJoinedRooms.count == 0 {
                                Rectangle()
                                    .frame(height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal)
                                    .foregroundStyle(Color.background)
                                    .overlay {
                                        VStack {
                                            Text("No rooms found")
                                                .foregroundStyle(Color.foreground)
                                            
                                            Button(action: { self.showNewRoom.toggle() }) {
                                                Text("Create One")
                                                    .font(.callout)
                                                    .padding(.vertical, 5)
                                            }
                                        }
                                    }
                            } else {
                                ForEach(notJoinedRooms) { room in
                                    Button(action:{ self.showDetail.toggle() }){
                                        RoomListItem(room: room, rooms: $rooms, observer: chatObserver)
                                            .padding(.bottom)
                                    }
                                    .fullScreenCover(isPresented: $showDetail) {
                                        GroupRoomView(room: room, rooms: $rooms)
                                    }
                                }
                            }
                        }
                        .refreshable {
                            await fetchChatRooms()
                        }
                        .tabItem {
                            Text("Not Joined")
                        }
                        .tag(1)

                    }
                    .tabViewStyle(.page)
                    .padding(.top)
                case .failure:
                    ScrollView {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 100)
                            .padding(.horizontal)
                            .foregroundStyle(Color.background)
                            .overlay(alignment: .center) {
                                VStack {
                                    Text("😞")
                                    Text("Failed to load rooms")
                                        .foregroundStyle(Color.foreground)
                                    
                                    Button(action: {
                                        Task {
                                            
                                        }
                                    }){
                                        Text("Try again")
                                    }
                                }
                            }
                            .padding(.top)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{ dismiss() }){
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigation) {
                    Text("Messages")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{self.showNewRoom.toggle()}){
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
            }
            .task {
                session.notificationsManager.inMessageView = true
                await fetchChatRooms()
            }
            .onDisappear {
                session.notificationsManager.inMessageView = false
            }
            .fullScreenCover(isPresented: $showNewRoom) {
                GroupNewRoom(rooms: $rooms)
            }
            .fullScreenCover(item: $selectedRoom, content: { r in
                GroupRoomView(room: r, rooms: $rooms)
            })
        }
    }
}

#Preview {
    GroupMessages(rooms: ROOMS)
        .environmentObject(SessionStore())
}
