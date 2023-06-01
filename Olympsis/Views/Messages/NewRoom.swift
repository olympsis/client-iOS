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
    
    @StateObject private var chatObserver = ChatObserver()
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func CreateRoom() async {
        if text.count >= 3 {
            withAnimation(.easeInOut){
                state = .loading
            }
            if let usr = session.user {
                let res = await chatObserver.CreateRoom(club: club.id!, name: text, uuid: usr.uuid!)
                if let r = res {
                    print(r.id)
                    rooms.append(r)
                }
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
        NavigationView {
            VStack (alignment: .leading){
                Text("New Chat Room")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                        .frame(width: SCREEN_WIDTH-20, height: 40)
                    TextField("Room name", text: $text)
                        .frame(width: SCREEN_WIDTH-20, height: 40)
                        .padding(.leading, 30)
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
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Text("cancel")
                            .foregroundColor(Color("primary-color"))
                    }
                }
            }
        }
    }
}

struct NewRoom_Previews: PreviewProvider {
    static var previews: some View {
        let club = CLUBS[0]
        let room = Room(id: "", name: "Admin's Chat", type: "Group", members: [ChatMember](), history: [Message]())
        NewRoom(club: .constant(club), rooms: .constant([room]))
    }
}
