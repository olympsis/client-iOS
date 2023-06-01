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
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    ForEach(club.members!) { member in
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
