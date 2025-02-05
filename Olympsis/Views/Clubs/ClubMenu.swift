//
//  ClubMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct ClubMenu: View {
    
    enum Alerts {
        case LeaveClub
        case DeleteClub
    }
    
    @State private var showAlert = false
    @State private var showOrganizations = false
    @State private var showClubs = false
    @State private var showReports = false
    @State private var showNewClub = false
    @State private var showEditClub = false
    @State private var showApplications = false
    @State private var showLeaveClubAlert = false
    @State private var showDeleteClubAlert = false
    @State private var alertType = Alerts.LeaveClub
    
    @StateObject private var clubObserver = ClubObserver()
    @StateObject private var postObserver = PostObserver()
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var club: Club
    @Environment(SessionStore.self) private var session
    
    // user's role
    var role: String {
        guard let user = session.user,
              let member = club.members.first(where: {$0.user?.uuid == user.uuid}) else {
            return "member"
        }
        return member.role ?? ""
    }
    
    // this will be handled in the backend as well
    var isOnlyOwner: Bool {
        let owners = club.members.filter({ $0.role == "owner" })
        return owners.count < 2
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                    
                ClubBanner()
                    .environmentObject(club)
                
                VStack {
                    if club.visibility == "private" {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(Color("color-prime"))
                            Text("Private group")
                                .font(.callout)
                            Spacer()
                        }.frame(height: 20)
                            
                    } else {
                        HStack {
                            Image(systemName: "globe.americas.fill")
                            Text("Public group")
                                .font(.callout)
                            Spacer()
                        }
                        .frame(height: 20)
                        .foregroundStyle(Color.foreground)
                    }
                    
                    HStack {
                        Text("\(club.members.count)") +
                        Text(" members")
                            .font(.callout)
                        Spacer()
                    }
                    .foregroundStyle(Color.foreground)
                    
                }.padding(.vertical)
                    .padding(.horizontal)
                
                VStack {
                    if role != "member" {
                        NavigationLink {
                            ClubEditor()
                                .environmentObject(club)
                                .environment(session)
                        } label: {
                            MenuLabel(icon: Image(systemName: "pencil"), text: "Edit Club")
                        }
                    }
                    
                    if role != "member" {
                        MenuButton(icon: Image(systemName: "note.text"), text: "Applications", action: {
                            self.showApplications.toggle()
                        })
                    }
                    
                    if role != "member" {
                        MenuButton(icon: Image(systemName: "ladybug"), text: "Reports", action: {
                            self.showReports.toggle()
                        })
                    }
                    
                    if role != "member" {
                        MenuButton(icon: Image(systemName: "building.fill"), text: "Change Organization", action: {
                            self.showOrganizations.toggle()
                        })
                    }
                            
                    MenuButton(icon: Image(systemName: "plus.circle.fill"), text: "Create a New Group", action: {
                        self.showNewClub.toggle()
                    })
                    
                    MenuButton(icon: Image(systemName: "magnifyingglass"), text: "Search for clubs", action: {
                        self.showClubs.toggle()
                    })
                    
                    NavigationLink {
                        MembersListView()
                            .environmentObject(club)
                    } label: {
                        MenuLabel(icon: Image(systemName: "person.3"), text: "Members")
                    }
                    
                    MenuButton(icon: Image(systemName: "door.left.hand.open"), text: "Leave Club", action: {
                        showAlert = false
                        alertType = .LeaveClub
                        showAlert.toggle()
                    }, type: .destructive)
                    
                    if role == "owner" {
                        MenuButton(icon: Image(systemName: "trash.fill"), text: "Delete Club", action: {
                            showAlert = false
                            alertType = .DeleteClub
                            showAlert.toggle()
                        }, type: .destructive)
                    }
                }.padding(.vertical)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{ dismiss() }){
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .navigationTitle(club.name)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showNewClub) {
                NewGroup()
            }
            .fullScreenCover(isPresented: $showApplications) {
                ClubApplications(club: club)
            }
            .fullScreenCover(isPresented: $showOrganizations) {
                OrganizationsView()
            }
            .fullScreenCover(isPresented: $showClubs) {
                ClubsList2()
            }
            .fullScreenCover(isPresented: $showReports, content: {
                GroupReports()
            })
            .alert(isPresented: $showAlert) {
                switch alertType {
                case .LeaveClub:
                    switch role {
                    case "owner":
                        if isOnlyOwner {
                            return Alert(
                                title: Text("About Leaving Club"),
                                message: Text("You cannot leave this club. You are the only owner. Please delete the club or appoint new owners."),
                                dismissButton: .default(Text("Ok"))
                            )
                        } else {
                            return Alert(
                                title: Text("Leaving Club"),
                                message: Text("Are you sure you want to leave this club?"),
                                primaryButton: .cancel(),
                                secondaryButton: .destructive(Text("Leave"), action: {
                                    Task { // Perform delete operation
                                        _ = await session.clubObserver.leaveClub(id: club.id)
                                        session.groups.removeAll(where: { $0.id == session.selectedGroup?.id })
                                        session.selectedGroup = session.groups.first
                                        dismiss()
                                    }
                                })
                            );
                        }
                    default:
                        return Alert(
                            title: Text("Leaving Club"),
                            message: Text("Are you sure you want to leave this club?"),
                            primaryButton: .cancel(),
                            secondaryButton: .destructive(Text("Leave"), action: {
                                Task { // Perform delete operation
                                    _ = await session.clubObserver.leaveClub(id: club.id)
                                    session.groups.removeAll(where: { $0.id == session.selectedGroup?.id })
                                    
                                    session.clubsState = .loading
                                    session.selectedGroup = nil
                                    if let next = session.groups.first {
                                        session.selectedGroup = next
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        session.clubsState = .success
                                        dismiss()
                                    }
                                }
                            })
                        );
                    }
                case .DeleteClub:
                    return Alert(
                        title: Text("Delete Club"),
                        message: Text("Are you sure you want to delete this club?"),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Delete"), action: {
                            Task { // Perform delete operation
                                _ = await session.clubObserver.deleteClub(id: club.id)
                                session.groups.removeAll(where: { $0.id == session.selectedGroup?.id })
                                
                                session.clubsState = .loading
                                session.selectedGroup = nil
                                if let next = session.groups.first {
                                    session.selectedGroup = next
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    session.clubsState = .success
                                    dismiss()
                                }
                            }
                        })
                    );
                }
            }
            .background(Color("background-color/primary"))
        }
    }
}

#Preview("Club Menu") {
    ClubMenu()
        .environmentObject(CLUBS[0])
        .environment(SessionStore())
}
