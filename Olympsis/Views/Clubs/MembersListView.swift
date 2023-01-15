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
                    ForEach(club.members) { member in
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
        let members = [Member(id: "0", uuid: "", role: "admin", data: UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"]), joinedAt: 0), Member(id: "1", uuid: "", role: "", data: UserPeek(firstName: "Jane", lastName: "Doe", username: "janedoe", imageURL: "", bio: "", sports: ["soccer"]), joinedAt: 0), Member(id: "2", uuid: "", role: "admin", data: nil, joinedAt: 0)]
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/clubs/315204106_2320093024813897_5616555109943012779_n.jpg", isPrivate: false, members: members, rules: ["No fighting"], createdAt: 0)
        MembersListView(club: club)
            .environmentObject(SessionStore())
    }
}
