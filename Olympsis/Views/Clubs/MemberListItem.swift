//
//  ClubMemberView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI
import Kingfisher

struct MemberListItem: View {
    
    @State private var showMenu: Bool = false
    
    @StateObject var member: Member
    @EnvironmentObject private var club: Club
    @EnvironmentObject private var session:SessionStore
    
    var username: String {
        guard let data = member.user, let username = data.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var userRole: String {
        guard let user = session.user,
              let member = club.members.first(where: {$0.user?.uuid == user.uuid}) else {
            return "member"
        }
        return member.role ?? ""
    }
    
    var memberIsUser: Bool {
        guard let user = session.user, let uuid = user.uuid else {
            return false
        }
        return uuid == member.user?.uuid
    }
    
//    var isBlocked: Bool {
//        guard let user = session.user else {
//            return false
//        }
//        return self.member.checkBlockStatus(user)
//    }
    
    init(member: Member) {
        self._member = StateObject(
            wrappedValue: member
        )
    }
    
    var body: some View {
        HStack {
            ZStack {
                AsyncImage(url: URL(string: GenerateImageURL((member.user?.imageURL ?? "")))){ phase in
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
            }.redacted(reason: member.isBlocked ? .placeholder : [])
            
            Group {
                
            }
            
            VStack(alignment: .leading) {
                Text(username)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }.redacted(reason: member.isBlocked ? .placeholder : [])
            
            Spacer()
            
            if !member.isBlocked {
                switch member.role {
                case "owner":
                    Image(systemName: "o.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.yellow)
                        .padding(.trailing, 5)
                case "admin":
                    Image(systemName: "a.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(Color("tertiary-color"))
                        .padding(.trailing, 5)
                case "moderator":
                    Image(systemName: "a.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.orange)
                        .padding(.trailing, 5)
                default:
                    EmptyView()
                }
            }
            
            if !memberIsUser {
                Button(action:{self.showMenu.toggle()}){
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }
                .padding(.trailing)
                .sheet(isPresented: $showMenu) {
                    ClubMemberMenu(club: club, role: userRole)
                        .environmentObject(member)
                        .presentationDetents([.height(250)])
                }
                .redacted(reason: member.isBlocked ? .placeholder : [])
                .disabled(member.isBlocked)
            }
        }.padding(.leading)
            .frame(height: 60)
            .onAppear {
                guard let user = session.user else {
                    return
                }
                member.checkBlockStatus(user)
            }
    }
}

#Preview("Club Member") {
    MemberListItem(member: CLUBS[0].members.first!)
        .environmentObject(CLUBS[0])
        .environmentObject(SessionStore())
}
