//
//  ClubMemberMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/11/23.
//

import os
import SwiftUI

struct ClubMemberMenu: View {
    
    @State var club: Club
    @State var role: String
    
    @State private var isBlocked: Bool = false
    @State private var showReport: Bool = false
    @State private var showBlocking: Bool = false
    
    @EnvironmentObject var member: Member
    @EnvironmentObject var session:SessionStore
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "club_member_menu_view")
    
    func promote(_ role: String) async {
        _ = await session.clubObserver.changeMemberRank(id: club.id, memberId: member.id!, role: role)
    }
    
    func demote(_ role: String) async {
        _ = await session.clubObserver.changeMemberRank(id: club.id, memberId: member.id!, role: role)
    }
    
    func kick() async {
        _ = await session.clubObserver.kickMember(id: club.id, memberId: member.id!)

    }
    
    func unBlock() async {
        guard let user = session.user,
              let data = member.user,
              let memberUID = data.uuid else {
            log.error("Failed to get required data from session store to un-block user")
            return
        }
        
        if var blockedList = user.blockedUsers {
            blockedList.removeAll(where: { $0 == memberUID })
            let dto = UserDao(blockedUsers: blockedList)
            
            guard let resp = await session.userObserver.UpdateUserData(update: dto) else {
                return
            }
            isBlocked = false
            session.user = resp
        }
    }
    
    var body: some View {
        VStack {
            if role != "member" {
                Menu {
                    Button(action:{ Task{ await promote("owner") } }) {
                        Text("Promote to Owner")
                    }
                    Button(action:{ Task{ await promote("admin") } }) {
                        Text("Promote to Admin")
                    }
                    Button(action:{ Task{ await demote("member") } }) {
                        Text("Demote to Member")
                    }
                    
                } label: {
                    MenuButton(icon: Image(systemName: "chevron.up.chevron.down"), text: "Change Role")
                }
            }
            
            MenuButton(icon: Image(systemName: "exclamationmark.bubble"), text: "Report Member") {
                showReport.toggle()
            }.fullScreenCover(isPresented: $showReport, content: {
                MemberReportView(member: member)
            })
            
            if isBlocked {
                MenuButton(icon: Image(systemName: "person"), text: "Unblock Member", action:  {
                    Task {
                        await unBlock()
                    }
                }).fullScreenCover(isPresented: $showReport, content: {
                    MemberReportView(member: member)
                })
            } else {
                MenuButton(icon: Image(systemName: "person.slash"), text: "Block Member", action:  {
                    showBlocking.toggle()
                }, type: .destructive)
                .sheet(isPresented: $showBlocking, content: {
                    MemberBlockingConfirmation()
                        .environmentObject(member)
                        .presentationDetents([.height(450), .medium])
                })
            }
            
            if role != "member" {
                MenuButton(icon: Image(systemName: "door.right.hand.open"), text: "Remove Member from Club", action: {
                    Task {
                        await kick()
                    }
                })
            }
            
            Spacer()
        }
        .background(Color("background-color/secondary"))
        .presentationDragIndicator(.visible)
        .padding(.top)
        .onAppear {
            guard let user = session.user else {
                return
            }
            member.checkBlockStatus(user)
            _ = member.$isBlocked
                .sink() {
                    self.isBlocked = $0
                }
        }
    }
}

struct ClubMemberMenu_Previews: PreviewProvider {
    static var previews: some View {
        ClubMemberMenu(club: CLUBS[0], role: "member")
            .environmentObject(SessionStore())
            .environmentObject(CLUBS[0].members.first!)
    }
}
