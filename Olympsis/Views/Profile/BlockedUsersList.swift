//
//  BlockedUsersList.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/21/24.
//

import os
import SwiftUI

struct BlockedUsersList: View {
    
    @State private var blockedUsers = [UserData]()
    @State private var state: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "blocked_users_list_view")
    
    func unBlock(usr: UserData) async {
        guard let user = session.user,
              let uuid = usr.uuid else {
            log.error("Failed to get required data from session store to un-block user")
            return
        }
        
        if var blockedList = user.blockedUsers {
            blockedList.removeAll(where: { $0 == uuid })
            let dto = UserDao(blockedUsers: blockedList)
            
            let resp = await session.userObserver.UpdateUserData(update: dto)
            if resp {
                session.user?.blockedUsers = blockedList
                blockedUsers.removeAll(where: { $0.uuid == uuid })
            }
        }
    }
    
    func loadList() async {
        state = .loading
        guard let user = session.user,
              let list = user.blockedUsers else {
            state = .failure
            return
        }
        do {
            for uuid in list {
                guard let data = try await session.userObserver.getUserByUUID(uuid: uuid) else {
                    return
                }
                blockedUsers.append(data)
            }
            state = .success
        } catch {
            state = .failure
            log.error("Failed to fetch users data: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        ScrollView {
            switch state {
            case .pending, .success:
                if blockedUsers.count > 0 {
                    ForEach(blockedUsers, id: \.self) { usr in
                        HStack {
                            AsyncImage(url: URL(string: GenerateImageURL((usr.imageURL ?? "")))){ phase in
                                if let image = phase.image {
                                    image // Displays the loaded image.
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50)
                                        .clipShape(Circle())
                                        .clipped()
                                    
                                } else if phase.error != nil {
                                    ZStack {
                                        Color.gray // Indicates an error.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                        Image(systemName: "person")
                                            .foregroundStyle(.white)
                                            .imageScale(.large)
                                    }
                                } else {
                                    ZStack {
                                        Color.gray // Acts as a placeholder.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                        ProgressView()
                                    }
                                }
                            }.frame(width: 50)
                            
                            Text(usr.username ?? "olympsis-user")
                            
                            Spacer()
                            
                            Menu {
                                Button(action: {
                                    Task {
                                        await unBlock(usr: usr)
                                    }
                                }) {
                                    Text("Unblock")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                            }
                        }.padding(.horizontal)
                    }
                } else {
                    Text("No blocked users")
                        .padding(.top, 100)
                }
            case .loading:
                ProgressView()
                    .padding(.top, 100)
            case .failure:
                VStack {
                    Text("Failed to load list. Pull to refresh or")
                    Button(action: { Task { await loadList() } } ) {
                        Text("Click Here")
                    }
                }
                .padding(.top, 100)
            }
        }
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .task {
            await loadList()
        }
        .refreshable {
            await loadList()
        }
    }
}

#Preview {
    NavigationStack {
        BlockedUsersList()
            .environmentObject(SessionStore())
    }
}
