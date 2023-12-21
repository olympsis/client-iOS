//
//  GroupNewRoom.swift
//  Olympsis
//
//  Created by Joel on 12/20/23.
//

import SwiftUI

struct GroupNewRoom: View {
    
    @Binding var org: Organization
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
            guard let user = session.user,
                  let uuid = user.uuid,
                  let groupID = org.id else {
                return
            }
            let res = await chatObserver.CreateRoom(group: groupID, groupType: "organization", name: text, type: "group", uuid: uuid)
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


#Preview {
    GroupNewRoom(org: .constant(ORGANIZATIONS[0]), rooms: .constant(ROOMS))
}
