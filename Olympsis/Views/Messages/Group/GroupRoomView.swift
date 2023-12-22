//
//  GroupRoomView.swift
//  Olympsis
//
//  Created by Joel on 12/20/23.
//

import os
import SwiftUI

struct GroupRoomView: View {
    
    @State var org: Organization
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
    @EnvironmentObject private var notificationManager: NotificationsManager
    
    var log = Logger(subsystem: "com.coronislabs.olympsis", category: "room_view")
    
    func SendMessage() {
        guard text.count > 0 else {
            return
        }
        guard let user = session.user,
              let uuid = user.uuid else {
            return
        }
        let message = Message(type: "text", sender: uuid, body: text)
        Task {
            let res = await observer.SendMessage(msg: message)
            if !res {
                log.error("failed to send message")
            }
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            text = ""
        }
    }
    
    func DidDismiss(){
        if hasDeleted {
            self.rooms.removeAll(where: {$0.id == room.id})
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func GetData(uuid: String) -> UserData? {
        guard let user = org.members!.first(where: {$0.uuid == uuid}) else {
            return nil
        }
        return user.data
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    if state == .loading {
                        ProgressView()
                    } else if state == .success {
                        ForEach(messages, id: \.timestamp){ message in
                            MessageView(room: room, data: GetData(uuid: message.sender), message: message)
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
                .refreshable {
                    state = .loading
                    guard let id = room.id else {
                        return
                    }
                    let resp = await observer.GetRoom(id: id)
                    if let r = resp {
                        await MainActor.run {
                            guard let history = r.history else {
                                state = .success
                                return
                            }
                            messages = history
                            state = .success
                        }
                    }
                    await observer.InitiateSocketConnection(id: id)
                    observer.Ping()
                    while true {
                        let msg = await observer.ReceiveMessage()
                        if let m = msg {
                            messages.append(m)
                        } else {
                            log.error("Failed to get message")
                            await observer.InitiateSocketConnection(id: id)
                            observer.Ping()
                        }
                    }
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
                                .foregroundColor(Color("color-prime"))
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
                notificationManager.inMessageView = true
                state = .loading
                guard let id = room.id else {
                    return
                }
                let resp = await observer.GetRoom(id: id)
                if let r = resp {
                    await MainActor.run {
                        guard let history = r.history else {
                            state = .success
                            return
                        }
                        messages = history
                        state = .success
                    }
                }
                await observer.InitiateSocketConnection(id: id)
                observer.Ping()
                while true {
                    let msg = await observer.ReceiveMessage()
                    if let m = msg {
                        messages.append(m)
                    } else {
                        log.error("Failed to get message")
                        await observer.InitiateSocketConnection(id: id)
                        observer.Ping()
                    }
                }
            }
            .onDisappear() {
                notificationManager.inMessageView = false
                Task {
                    await observer.CloseSocketConnection()
                }
            }
        }
    }
}

#Preview {
    GroupRoomView(org: ORGANIZATIONS[0], room: ROOMS[0], rooms: .constant(ROOMS), observer: ChatObserver())
        .environmentObject(SessionStore())
        .environmentObject(NotificationsManager())
}