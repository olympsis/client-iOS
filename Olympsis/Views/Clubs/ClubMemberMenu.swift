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
            
            if role != "member" {
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
        ClubMemberMenu(club: CLUBS[0], role: "member", member: CLUBS[0].members!.first!)
    }
}
