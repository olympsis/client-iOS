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
        let res = await observer.changeMemberRank(id: club.id!, memberId: member.id!, role: "admin")
        // FETCH NEW CLUB DATA TO UPDATE MEMBERS
    }
    
    func Demote() async {
        let res = await observer.changeMemberRank(id: club.id!, memberId: member.id!, role: "member")
        if res {
            // FETCH NEW CLUB DATA TO UPDATE MEMBERS
        }
    }
    
    func Kick() async {
        let res = await observer.kickMember(id: club.id!, memberId: member.id!)
        // FETCH NEW CLUB DATA TO UPDATE MEMBERS
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
        ClubMemberMenu(club: CLUBS[0], role: .Member, member: CLUBS[0].members!.first!)
    }
}
