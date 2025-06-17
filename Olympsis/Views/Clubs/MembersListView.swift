//
//  MembersListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/11/23.
//

import SwiftUI

struct MembersListView: View {
    
    @State private var text: String = ""
    @EnvironmentObject private var club: Club
    
    private var members: [Member] {
        return club.members
            .filter {
                $0.user?.username != nil && text.isEmpty ||
                $0.user?.username != nil && $0.user?.username!.lowercased().contains(text.lowercased()) ?? false
            }
            .sorted(by: { (member1, member2) -> Bool in
                if member1.role == MEMBER_ROLES.Owner.rawValue {
                    return true
                } else if member2.role == MEMBER_ROLES.Owner.rawValue {
                    return false
                } else if member1.role == MEMBER_ROLES.Admin.rawValue {
                    return true
                } else if member2.role == MEMBER_ROLES.Admin.rawValue {
                    return false
                } else {
                    return member1.joinedAt ?? Date() > member2.joinedAt ?? Date()
                }
            })
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            SearchBar(text: $text)
                .padding(.top, 10)
                .padding(.horizontal)
            
            VStack (spacing: 5) {
                ForEach(members) { member in
                    MemberListItem(member: member)
                        .environmentObject(club)
                }.padding(.top)
            }
        }
        .navigationTitle(String(localized: "group-menu-members", table: "Groups"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MembersListView()
            .environmentObject(CLUBS[0])
            .environment(SessionStore())
    }
}
