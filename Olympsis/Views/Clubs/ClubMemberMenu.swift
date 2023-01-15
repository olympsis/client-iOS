//
//  ClubMemberMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/11/23.
//

import SwiftUI

struct ClubMemberMenu: View {
    @State var club: Club
    @State var role: MEMBER_ROLES
    @State var member: Member
    @State var observer = ClubObserver()
    
    func Promote() async {
        let res = await observer.changeMemberRank(id: club.id, memberId: member.id, role: "admin")
        if res {
            await MainActor.run {
                member.role = "admin"
            }
        }
    }
    
    func Demote() async {
        let res = await observer.changeMemberRank(id: club.id, memberId: member.id, role: "member")
        if res {
            await MainActor.run {
                member.role = "member"
            }
        }
    }
    
    func Kick() async {
        let res = await observer.kickMember(id: club.id, memberId: member.id)
        if res {
            await MainActor.run {
                club.members.removeAll(where: {$0.id == member.id})
            }
        }
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 5)
                .foregroundColor(.gray)
                .opacity(0.3)
                .padding(.bottom, 1)
                .padding(.top, 7)
            
            if role != .Member {
                Menu {
                    Button(action:{ Task{ await Promote() } }) {
                        Text("Promote to Admin")
                    }
                    Button(action:{ Task{ await Demote() } }) {
                        Text("Demote to Member")
                    }
                    
                } label: {
                    HStack {
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.large)
                            .padding(.leading)
                            .foregroundColor(.primary)
                        Text("Change Role")
                            .foregroundColor(.primary)
                        Spacer()
                    }.modifier(MenuButton())
                }

            }
            
            Button(action:{}) {
                HStack {
                    Image(systemName: "exclamationmark.bubble")
                        .imageScale(.large)
                        .padding(.leading)
                        .foregroundColor(.primary)
                    Text("Report Member")
                        .foregroundColor(.primary)
                    Spacer()
                }.modifier(MenuButton())
            }
            
            if role != .Member {
                Button(action:{ Task{ await Kick() } }) {
                    HStack {
                        Image(systemName: "door.right.hand.open")
                            .imageScale(.large)
                            .padding(.leading)
                            .foregroundColor(.red)
                        Text("Kick Member")
                            .foregroundColor(.red)
                        Spacer()
                    }.modifier(MenuButton())
                }
            }
            
            Spacer()
        }
    }
}

struct ClubMemberMenu_Previews: PreviewProvider {
    static var previews: some View {
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/clubs/315204106_2320093024813897_5616555109943012779_n.jpg", isPrivate: false, members: [Member](), rules: ["No fighting"], createdAt: 0)
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"])
        let member = Member(id: "", uuid: "", role: "admin", data: peek, joinedAt: 0)
        ClubMemberMenu(club: club, role: .Member, member: member)
    }
}
