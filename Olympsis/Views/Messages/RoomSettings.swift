//
//  RoomSettings.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/7/23.
//

import SwiftUI

struct RoomSettingsView: View {
    
    @State var room: Room
    @Binding var hasDeleted: Bool
    @State var observer: ChatObserver
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func DeleteRoom() async {
        guard let id = room.id else {
            return
        }
        let res = await observer.DeleteRoom(id: id)
        if res {
            hasDeleted = true
            self.presentationMode.wrappedValue.dismiss()
        } else {
            print("failed to delete room")
        }
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 5)
                .foregroundColor(.gray)
                .opacity(0.3)
                .padding(.bottom)
                .padding(.top, 5)
            Button(action:{}) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                    HStack {
                        Image(systemName: "exclamationmark.shield")
                            .imageScale(.large)
                            .padding(.leading)
                            .foregroundColor(.black)
                        Text("Report an Issue")
                            .foregroundColor(.black)
                        Spacer()
                    }
                }.frame(width: SCREEN_WIDTH-25, height: 50)
            }
            
            Button(action:{
                Task {
                    await DeleteRoom()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                    HStack {
                        Image(systemName: "exclamationmark.shield")
                            .imageScale(.large)
                            .padding(.leading)
                            .foregroundColor(.red)
                        Text("Delete Chat Room")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }.frame(width: SCREEN_WIDTH-25, height: 50)
            }
            Spacer()
        }
    }
}

struct RoomSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let room = Room(id: "", name: "Admin's Chat", type: "Group", group: GroupModel(id: UUID().uuidString, type: "club"), members: [ChatMember](), history: [Message]())
        RoomSettingsView(room: room, hasDeleted: .constant(false), observer: ChatObserver())
            .environmentObject(SessionStore())
    }
}
