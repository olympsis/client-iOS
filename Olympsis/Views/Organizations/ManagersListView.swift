//
//  ManagersListView.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import SwiftUI

struct ManagersListView: View {
    
    @State var organization: Organization
    @State private var showInvitations = false
    @Environment(\.dismiss) private var dismiss
    
    var members: [Member] {
        guard var members = organization.members else {
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
        NavigationStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    ForEach(members) { member in
                        ManagerView(member: member)
                    }.padding(.top)
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{dismiss()}){
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Managers")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { self.showInvitations.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }.fullScreenCover(isPresented: $showInvitations, content: {
                OrgManagerInvite()
            })
        }
    }
}

#Preview {
    ManagersListView(organization: ORGANIZATIONS[0])
}
