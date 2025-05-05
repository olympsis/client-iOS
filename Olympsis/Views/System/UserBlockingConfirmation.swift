//
//  UserBlockingConfirmation.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/21/24.
//

import os
import SwiftUI
import Kingfisher

struct UserBlockingConfirmation: View {
    
    var user: UserSnippet
    var onComplete: (Bool) -> Void
    
    @State private var status: LOADING_STATE = .pending
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "user_blocking_confirmation_view")
    
    var username: String {
        guard let username = user.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var imageURL: URL? {
        guard let link = user.imageURL,
              let url = URL(string: GenerateImageURL(link)) else {
            return nil
        }
        return url
    }
    
    func block() async {
        status = .loading
        guard let _user = session.user,
              let memberUID = user.uuid else {
            handleFailure()
            onComplete(false)
            log.error("Failed to get required data from session store to block user")
            return
        }
        
        if var blockedList = _user.blockedUsers {
            blockedList.append(memberUID)
            let dto = UserDao(blockedUsers: blockedList)
            
            guard let user = await session.userObserver.UpdateUserData(update: dto) else {
                return
            }
            session.user = user
        } else {
            var blockedList = [String]()
            blockedList.append(memberUID)
            let dto = UserDao(blockedUsers: blockedList)
            
            guard let user = await session.userObserver.UpdateUserData(update: dto) else {
                return
            }
            session.user = user
        }
        status = .success
        onComplete(true)
        dismiss()
    }
    
    
    private func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    var body: some View {
        VStack {
            
            ScrollView {
                Group {
                    if let url = imageURL {
                        KFImage(url)
                            .placeholder({
                                ImageLoadingView()
                            })
                            .resizable()
                            .clipShape(Circle())
                            .scaledToFill()
                            .clipped()
                            .frame(width: 100, height: 100)
                    } else {
                        ZStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.red)
                            Color(Color.Background.secondary) // Acts as a placeholder.
                                .clipShape(Circle())
                                .opacity(0.3)
                        }.frame(width: 100, height: 100)
                    }
                }.padding(.bottom)
                
                Text("Block \(username)?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This will block them from interacting with you.")
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "newspaper")
                        Text("You will not see their posts on your feed")
                            .font(.callout)
                    }.padding(.top, 5)
                    
                    HStack {
                        Image(systemName: "bell.slash")
                        Text("They won't know that you blocked them")
                            .font(.callout)
                    }.padding(.top, 5)
                    
                    HStack {
                        Image(systemName: "bubble")
                        Text("You will still see their messages in group chats")
                            .font(.callout)
                    }.padding(.top, 5)
                    
                    HStack {
                        Image(systemName: "gearshape")
                        Text("You can update your block lists in your settings")
                            .font(.callout)
                    }.padding(.top, 5)
                }.padding(.horizontal)
            }
            
            HStack {
                Button(action: {
                    Task {
                        await block()
                    }
                }) {
                    LoadingButton(text: "Block", status: $status)
                }
            }
        }.presentationDragIndicator(.visible)
            .padding(.top)
            .scrollIndicators(.never)
    }
}

#Preview {
    UserBlockingConfirmation(user: USER_SNIPPETS[0], onComplete: { _ in })
}
