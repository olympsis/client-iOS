//
//  BlockedUsersList.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/21/24.
//

import os
import SwiftUI

struct BlockedUsersList: View {
    
    @State private var blockedUsers = [User]()
    @State private var state: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "blocked_users_list_view")
    
    func unBlock(usr: User) async {
        guard let user = session.user,
              let targetUserID = usr.userID else {
            log.error("Failed to get required data from session store to un-block user")
            return
        }
        
        if var blockedList = user.blockedUsers {
            blockedList.removeAll(where: { $0 == targetUserID })
            let dto = UserDao(blockedUsers: blockedList)
            
            guard let resp = await session.userObserver.UpdateUserData(update: dto) else {
                return
            }
            session.user = resp
            blockedUsers.removeAll(where: { $0.userID == targetUserID })
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
            for id in list {
                guard let data = try await session.userObserver.getUserByUserID(userID: id) else {
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
                                    Text(String(localized: "unblock", table: "General"))
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                            }
                        }.padding(.horizontal)
                    }
                } else {
                    Text(String(localized: "no-blocked-users-text", table: "Settings"))
                        .padding(.top, 100)
                }
            case .loading:
                ProgressView()
                    .padding(.top, 100)
            case .failure:
                VStack {
                    Text(String(localized: "failed-reports-load-text", table: "Settings"))
                    Button(action: { Task { await loadList() } } ) {
                        Text(String(localized: "click-here", table: "General"))
                    }
                }
                .padding(.top, 100)
            }
        }
        .navigationTitle(String(localized: "setting-blocked-users", table: "Settings"))
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
            .environment(SessionStore())
    }
}
