//
//  RoomListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/4/23.
//

import SwiftUI

struct RoomListView: View {
    @State var room: Room
    @Binding var rooms: [Room]
    @State var observer: ChatObserver
    @State private var hasJoined = false
    @EnvironmentObject private var session: SessionStore
    var body: some View {
        HStack {
            Circle()
                .frame(width: 50)
                .padding(.leading)
                .foregroundColor(.primary)
            Text(room.name)
                .font(.body)
                .padding(.leading, 10)
                .foregroundColor(.primary)
            Spacer()
            if !hasJoined {
                Button(action:{
                    Task{
                        let res = await observer.JoinRoom(id:room.id)
                        if let r = res {
                            let index = self.$rooms.firstIndex(where: {$0.id == r.id})
                            if let i = index {
                                self.rooms.remove(at: i)
                                rooms.append(r)
                                withAnimation(.easeOut){
                                    hasJoined = true
                                }
                            }
                        }
                    }
                }){
                    ZStack {
                        Rectangle()
                            .frame(width: 100, height: 50)
                            .foregroundColor(Color("primary-color"))
                        Text("Join")
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing)
            }
        }.task {
            if let usr = session.user {
                if !room.members.contains(where: {$0.uuid == usr.uuid}){
                    hasJoined = false
                } else {
                    hasJoined = true
                }
            }
        }
    }
}

struct RoomListView_Previews: PreviewProvider {
    static var previews: some View {
        let room = Room(id: "", name: "Admin's Chat", type: "Group", members: [ChatMember](), history: [Message]())
        RoomListView(room: room, rooms: .constant([Room]()), observer: ChatObserver())
            .environmentObject(SessionStore())
    }
}
