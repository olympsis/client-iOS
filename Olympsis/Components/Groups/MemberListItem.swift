//
//  ClubMemberView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI
import Kingfisher

struct MemberListItem: View {
    
    @StateObject var member: Member
    private var enableMenu: Bool = true
    
    @State private var showMenu: Bool = false
    @EnvironmentObject private var club: Club
    @Environment(SessionStore.self) private var session
    
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
    
    var userImageURL: URL? {
        guard let user = member.user,
              let imageURLString = user.imageURL,
              let url = generateImageURL(imageURLString) else {
            return nil
        }
        
        return url
    }
    
    var memberIsUser: Bool {
        guard let user = session.user, let uuid = user.uuid else {
            return false
        }
        return uuid == member.user?.uuid
    }
    
    init(member: Member, enableMenu: Bool = true) {
        self._member = StateObject(
            wrappedValue: member
        )
        self.enableMenu = enableMenu
    }
    
    var body: some View {
        HStack {
            UserBadgeView(size: .medium, imageURL: userImageURL)
                .redacted(reason: member.isBlocked ? .placeholder : [])
            
            VStack(alignment: .leading) {
                Text(username)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                switch member.role {
                case "owner":
                    Text(String(localized: "role-owner", table: "Groups"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(Color.Brand.tertiary)
                    
                case "admin":
                    Text(String(localized: "role-admin", table: "Groups"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(Color.Brand.secondary)
                    
                case "moderator":
                    Text(String(localized: "role-moderator", table: "Groups"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(Color.gray)
                default:
                    EmptyView()
                }
            }
            .padding(.leading, 10)
            .redacted(reason: member.isBlocked ? .placeholder : [])
            
            Spacer()
            
            if !memberIsUser && enableMenu {
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
        }
        .padding(.leading)
        .frame(height: 60)
        .onAppear {
            guard let user = session.user else {
                return
            }
            member.checkBlockStatus(user)
        }
    }
}

#Preview {
    MemberListItem(member: CLUBS[0].members.first!)
        .environmentObject(CLUBS[0])
        .environment(SessionStore())
}
