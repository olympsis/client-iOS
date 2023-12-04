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
    @State private var joined = false
    @State private var state: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    
    var isJoined: Bool {
        guard let user = session.user,
              let uuid = user.uuid else {
            return false
        }
        return room.members.contains(where: {$0.uuid == uuid})
    }
    
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
            if !isJoined {
                Button(action:{
                    Task{
                        withAnimation(.easeInOut) {
                            state = .loading
                        }
                        guard let id = room.id,
                                let user = session.user,
                              let uuid = user.uuid else {
                            state = .failure
                            return
                        }
                        let member = ChatMember(id: nil, uuid: uuid, status: "live")
                        let res = await observer.JoinRoom(id: id, member: member)
                        if let r = res {
                            let index = self.$rooms.firstIndex(where: {$0.id == r.id})
                            if let i = index {
                                self.rooms.remove(at: i)
                                rooms.append(r)
                                withAnimation(.easeOut){
                                    state = .success
                                    joined = true
                                }
                            }
                        }
                    }
                }){
                    LoadingButton(text: "Join", width: 100, status: $state)
                        .frame(width: 100)
                }
                .padding(.trailing)
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
