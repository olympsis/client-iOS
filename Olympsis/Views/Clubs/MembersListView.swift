//
//  MembersListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/11/23.
//

import SwiftUI

struct MembersListView: View {
    
    @EnvironmentObject private var club: Club
    @Environment(\.dismiss) private var dismiss
    
//     MOVE SORTING TO FUNCTION
//    var members: [Member] {
//        guard var members = club.members else {
//            return [Member]()
//        }
//        
//        members.sort(by: { (member1, member2) -> Bool in
//            if member1.role == MEMBER_ROLES.Owner.rawValue {
//                return true
//            } else if member2.role == MEMBER_ROLES.Owner.rawValue {
//                return false
//            } else if member1.role == MEMBER_ROLES.Admin.rawValue {
//                return true
//            } else if member2.role == MEMBER_ROLES.Admin.rawValue {
//                return false
//            } else {
//                return member1.joinedAt! > member2.joinedAt!
//            }
//        })
//        return members
//    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(club.members) { member in
                MemberListItem(member: member)
                    .environmentObject(club)
            }.padding(.top)
        }
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

struct MembersListView_Previews: PreviewProvider {
    static var previews: some View {
        MembersListView()
            .environmentObject(CLUBS[0])
            .environmentObject(SessionStore())
    }
}
