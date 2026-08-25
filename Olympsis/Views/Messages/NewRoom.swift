//
//  NewRoom.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/7/23.
//

import SwiftUI

struct NewRoom: View {
    
    @Binding var club: Club
    @Binding var rooms: [Room]
    @State private var text = ""
    @State private var state: LOADING_STATE = .pending
    
    private let chatService = ChatService()
    @Environment(SessionStore.self) private var session
    @Environment(\.presentationMode) var presentationMode
    
    func CreateRoom() async {
        if text.count >= 3 {
            withAnimation(.easeInOut){
                state = .loading
            }
            guard let user = session.user,
                  let userID = user.userID else {
                return
            }
            let res = await chatService.CreateRoom(group: club.id, groupType: "club", name: text, type: "group", userID: userID)
            if let r = res {
                rooms.append(r)
            }
            withAnimation(.easeOut){
                state = .success
            }
            self.presentationMode.wrappedValue.dismiss()
        } else {
            withAnimation(.easeOut){
                state = .failure
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut){
                    state = .pending
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading){
                Text("New Chat Room")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                        .frame(height: 40)
                    TextField("Room name", text: $text)
                        .frame(height: 40)
                        .padding(.leading)
                }
                Spacer()
                Button(action:{
                    Task {
                        await CreateRoom()
                    }
                }){
                    VStack {
                        LoadingButton(text: "Create", width: 100, status: $state)
                    }.frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 50)
                        .padding(.horizontal, 50)
                }
            }.padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Text("cancel")
                            .foregroundColor(Color("color-prime"))
                    }
                }
            }
        }
    }
}

struct NewRoom_Previews: PreviewProvider {
    static var previews: some View {
        let club = CLUBS[0]
        let room = Room(id: "", name: "Admin's Chat", type: "Group", group: GroupModel(id: club.id, type: "club"), members: [ChatMember](), history: [Message]())
        NewRoom(club: .constant(club), rooms: .constant([room]))
    }
}
