//
//  ClubMemberMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/11/23.
//

import SwiftUI

struct ClubMemberMenu: View {
    @State var club: Club
    @State var role: String
    @State var member: Member
    @EnvironmentObject var session:SessionStore
    
    func Promote(_ role: String) async {
        let res = await session.clubObserver.changeMemberRank(id: club.id!, memberId: member.id!, role: role)
        if res {
            await session.fetchUserClubs()
        }
    }
    
    func Demote(_ role: String) async {
        let res = await session.clubObserver.changeMemberRank(id: club.id!, memberId: member.id!, role: role)
        if res {
            await session.fetchUserClubs()
        }
    }
    
    func Kick() async {
        let res = await session.clubObserver.kickMember(id: club.id!, memberId: member.id!)
        if res {
            await session.fetchUserClubs()
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
            
            if role != "member" {
                Menu {
                    Button(action:{ Task{ await Promote("owner") } }) {
                        Text("Promote to Owner")
                    }
                    Button(action:{ Task{ await Promote("admin") } }) {
                        Text("Promote to Admin")
                    }
                    Button(action:{ Task{ await Demote("member") } }) {
                        Text("Demote to Member")
                    }
                    
                } label: {
                    MenuButton(icon: Image(systemName: "chevron.up.chevron.down"), text: "Change Role")
                }

            }
            
            MenuButton(icon: Image(systemName: "exclamationmark.bubble"), text: "Report Member", action: {})
            
            if role != "member" {
                MenuButton(icon: Image(systemName: "door.right.hand.open"), text: "Remove Member from Club", action: {
                    Task {
                        await Kick()
                    }
                })
            }
            
            Spacer()
        }
    }
}

struct ClubMemberMenu_Previews: PreviewProvider {
    static var previews: some View {
        ClubMemberMenu(club: CLUBS[0], role: "member", member: CLUBS[0].members!.first!)
    }
}
