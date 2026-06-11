//
//  RoomListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/4/23.
//

import SwiftUI

struct RoomListItem: View {
    
    @State var room: Room
    @Binding var rooms: [Room]
    @State var observer: ChatObserver
    @State private var joined = false
    @State private var state: LOADING_STATE = .pending
    @Environment(SessionStore.self) private var session
    
    var isJoined: Bool {
        guard let user = session.user,
              let userID = user.userID else {
            return false
        }
        return room.members.contains(where: {$0.userID == userID})
    }
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 50)
                .overlay(alignment: .center) {
                    Image(systemName: "rectangle.3.group.fill")
                        .foregroundStyle(Color.Foreground.default)
                }
                .padding(.horizontal)
            
            Text(room.name)
                .font(.body)
                .lineLimit(1)
                .foregroundColor(Color.Foreground.default)
            
            Spacer()
            if !isJoined {
                Button(action:{
                    Task{
                        withAnimation(.easeInOut) {
                            state = .loading
                        }
                        guard let id = room.id,
                                let user = session.user,
                              let userID = user.userID else {
                            state = .failure
                            return
                        }
                        let member = ChatMember(id: nil, userID: userID, status: "live")
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

#Preview {
    RoomListItem(room: ROOMS[0], rooms: .constant([Room]()), observer: ChatObserver())
        .environment(SessionStore())
}
