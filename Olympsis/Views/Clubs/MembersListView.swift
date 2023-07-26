//
//  MembersListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/11/23.
//

import SwiftUI

struct MembersListView: View {
    
    @State var club: Club
    @Environment(\.dismiss) private var dismiss
    
    var members: [Member] {
        guard var members = club.members else {
            return [Member]()
        }
        
        members.sort(by: { (member1, member2) -> Bool in
            if member1.role == MEMBER_ROLES.Owner.rawValue {
                return true
            } else if member2.role == MEMBER_ROLES.Owner.rawValue {
                return false
            } else if member1.role == MEMBER_ROLES.Admin.rawValue {
                return true
            } else if member2.role == MEMBER_ROLES.Admin.rawValue {
                return false
            } else {
                return member1.joinedAt! > member2.joinedAt!
            }
        })
        return members
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    ForEach(members) { member in
                        ClubMemberView(club: club, member: member)
                    }.padding(.top)
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{dismiss()}){
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Members")
                }
            }
        }
    }
}

struct MembersListView_Previews: PreviewProvider {
    static var previews: some View {
        MembersListView(club: CLUBS[0])
            .environmentObject(SessionStore())
    }
}
