//
//  RoomDetailView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/4/23.
//

import SwiftUI

struct RoomView: View {
    
    @State var club: Club
    @State var room: Room
    @Binding var rooms: [Room]
    @State var messages = [Message]()
    @State var observer: ChatObserver
    
    @State private var text = ""
    @State private var showMenu = false
    
    @State private var hasDeleted = false
    
    @State private var state: LOADING_STATE = .pending
    
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func SendMessage() {
        guard text.count > 0 else {
            return
        }
        if let usr = session.user {
            let message = Message(id: "", type: "text", from: usr.uuid, body: text, timestamp: 0)
            Task {
                let res = await observer.SendMessage(msg: message)
                if !res {
                    print("failed to send message")
                }
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                text = ""
            }
        }
    }
    
    func DidDismiss(){
        if hasDeleted {
            self.rooms.removeAll(where: {$0.id == room.id})
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func GetData(uuid: String) -> UserPeek? {
        let usr = club.members.first(where: {$0.uuid == uuid})
        if let u = usr {
            return u.data
        }
        return nil
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    if state == .loading {
                        ProgressView()
                    } else if state == .success {
                        ForEach(messages){ message in
                            MessageView(room: room, data: GetData(uuid: message.from), message: message)
                                .padding(.top)
                        }
                    } else if state == .failure {
                        Text("Failed to get messages 😞")
                            .font(.caption)
                            .padding(.top, 50)
                    }
                }.onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                }
                .sheet(isPresented: $showMenu, onDismiss: DidDismiss) {
                    RoomSettingsView(room: room, hasDeleted: $hasDeleted, observer: observer)
                        .presentationDetents([.height(250)])
                }
               
                HStack {
                    TextField("Message", text: $text, axis: .vertical)
                        .padding(.leading)
                        .lineLimit(3)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        
                        
                    if text != "" {
                        Button(action:{SendMessage()}){
                            Text("Send")
                                .foregroundColor(Color("primary-color"))
                                .padding(.trailing)
                        }
                    }
                }
                .frame(width: SCREEN_WIDTH-10)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.primary)
                        .opacity(0.1)
                        
                }
                .padding(.bottom, 5)
                
            }.toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(room.name)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{self.showMenu.toggle()}){
                        Circle()
                            .frame(width: 30)
                            .foregroundColor(.primary)
                    }
                }
            }
            .task {
                state = .loading
                messages = room.history
                let resp = await observer.GetRoom(id: room.id)
                if let r = resp {
                    await MainActor.run {
                        messages = r.history
                        state = .success
                    }
                }
                await observer.InitiateSocketConnection(id: room.id)
                observer.Ping()
                while true {
                    let msg = await observer.ReceiveMessage()
                    if let m = msg {
                        messages.append(m)
                    } else {
                        print("Failed to get message")
                        await observer.InitiateSocketConnection(id: room.id)
                        observer.Ping()
                    }
                }
            }
            .onDisappear() {
                Task {
                    await observer.CloseSocketConnection()
                }
            }
        }
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        let room = Room(id: "", name: "Admin's Chat", type: "Group", members: [ChatMember](), history: [Message]())
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/clubs/315204106_2320093024813897_5616555109943012779_n.jpg", isPrivate: false, members: [Member](), rules: ["No fighting"], createdAt: 0)
        RoomView(club: club, room: room, rooms: .constant([room]), observer: ChatObserver())
            .environmentObject(SessionStore())
    }
}
