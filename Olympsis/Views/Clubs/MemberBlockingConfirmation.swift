//
//  BlockUserView.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/20/24.
//

import os
import SwiftUI
import Kingfisher

struct MemberBlockingConfirmation: View {

    @State private var status: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var member: Member
    @Environment(SessionStore.self) private var session
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "member_blocking_confirmation_view")
    
    var username: String {
        guard let user = member.user,
            let username = user.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var imageURL: URL? {
        guard let user = member.user,
            let link = user.imageURL,
              let url = URL(string: GenerateImageURL(link)) else {
            return nil
        }
        return url
    }
    
    func block() async {
        status = .loading
        guard let user = session.user,
              let data = member.user,
              let memberUID = data.uuid else {
            handleFailure()
            log.error("Failed to get required data from session store to block user")
            return
        }
        
        if var blockedList = user.blockedUsers {
            blockedList.append(memberUID)
            let dto = UserDao(blockedUsers: blockedList)
            
            guard let resp = await session.userObserver.UpdateUserData(update: dto) else {
                return
            }
            member.isBlocked = true
            session.user = resp
        } else {
            var blockedList = [String]()
            blockedList.append(memberUID)
            let dto = UserDao(blockedUsers: blockedList)
            
            guard let resp = await session.userObserver.UpdateUserData(update: dto) else {
                return
            }
            member.isBlocked = true
            session.user = resp
        }
        status = .success
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
                        Text("You will see their text bubbles in group chats but the contents will be redacted")
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
        }
        .padding(.top)
        .scrollIndicators(.never)
        .presentationDragIndicator(.visible)
        .background(Color.Background.secondary)
    }
}

#Preview {
    MemberBlockingConfirmation()
        .environment(SessionStore())
        .environmentObject(CLUBS[0].members.first!)
}
