//
//  GroupRoomView.swift
//  Olympsis
//
//  Created by Joel on 12/20/23.
//

import os
import SwiftUI

struct GroupRoomView: View {
    
    @State var room: Room
    @Binding var rooms: [Room]
    @State private var viewModel: RoomViewModel
    
    @State private var showMenu = false
    @State private var hasDeleted = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    private var log = Logger(subsystem: "com.olympsis.client", category: "room_view")
    
    init(room: Room, rooms: Binding<[Room]>) {
        _rooms = rooms
        self.room = room
        let observer = ChatObserver()
        self._viewModel = State(initialValue: RoomViewModel(room: room, observer: observer))
    }
    
    private func didDismiss() {
        if hasDeleted {
            rooms.removeAll(where: { $0.id == viewModel.room.id })
            dismiss()
        }
    }
    
    private func getUserData(uuid: String) -> UserSnippet? {
        guard let selectedGroup = session.selectedGroup else {
            log.error("Failed to find the selected group!")
            return nil
        }
        if selectedGroup.type == .Club {
            guard let members = selectedGroup.club?.members,
                  let user = members.first(where: {$0.user?.uuid == uuid}) else {
                log.error("Failed to find club's members")
                return nil
            }
            return user.user
        } else {
            guard let members = selectedGroup.organization?.members,
                  let user = members.first(where: {$0.user?.uuid == uuid}) else {
                log.error("Failed to find club's members")
                return nil
            }
            return user.user
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { scrollView in
                    ScrollView(showsIndicators: false) {
                        switch viewModel.state {
                        case .pending, .loading:
                            ProgressView()
                        case .success:
                            ForEach(viewModel.messages, id: \.timestamp){ message in
                                MessageView(room: room, user: getUserData(uuid: message.sender), message: message)
                                    .id(message.id)
                                    .padding(.top)
                            }
                        case .failure:
                            Text("Failed to get messages 😞")
                                .font(.caption)
                                .padding(.top, 50)
                        }
                    }
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                     to: nil, from: nil, for: nil)
                    }
                    .sheet(isPresented: $showMenu, onDismiss: didDismiss) {
                        RoomSettingsView(room: viewModel.room,
                                       hasDeleted: $hasDeleted,
                                       observer: viewModel.observer)
                            .presentationDetents([.height(250)])
                    }
                    .onChange(of: viewModel.messages) { _, newValue in
                        withAnimation {
                            scrollView.scrollTo(newValue.last?.id, anchor: .bottom)
                        }
                    }
                }
               
                HStack {
                    TextField("Message", text: $viewModel.text, axis: .vertical)
                        .lineLimit(4)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 5)
                    
                    if !viewModel.text.isEmpty {
                        Button(action: {
                            Task {
                                _ = await viewModel.sendMessage(uuid: session.user?.uuid)
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                             to: nil, from: nil, for: nil)
                            }
                        }) {
                            Text("Send")
                                .foregroundStyle(.white)
                                .padding(.all, 5)
                        }
                        .background(Color("color-prime"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.trailing, 5)
                    }
                }
                .padding(.horizontal, 10)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.primary)
                        .opacity(0.1)
                        .padding(.horizontal, 5)
                }
                .padding(.bottom, 5)
                .padding(.horizontal, 5)
                .disabled(viewModel.state != .success)
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{
                        Task {
                            session.notificationsManager.inMessageView = false
                            await viewModel.disconnect()
                            dismiss()
                        }
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
                session.notificationsManager.inMessageView = true
                await viewModel.loadInitialData()
                await viewModel.startWebSocketConnection()
            }
            .onDisappear {
                session.notificationsManager.inMessageView = false
                Task {
                    await viewModel.disconnect()
                }
            }
        }
    }
}

#Preview {
    GroupRoomView(room: ROOMS[0], rooms: .constant(ROOMS))
        .environmentObject(SessionStore())
}
