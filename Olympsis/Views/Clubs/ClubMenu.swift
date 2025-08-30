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
    @State private var showEditClub = false
    @State private var showLeaveClubAlert = false
    @State private var showDeleteClubAlert = false
    @State private var alertType = Alerts.LeaveClub
    
    @StateObject private var clubObserver = ClubObserver()
    @StateObject private var postObserver = PostObserver()
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(Club.self) private var club
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
                    
                ClubLogoBanner()
                    .environment(club)
                
                HStack(alignment: .bottom) {
                    VStack {
                        if club.visibility == "private" {
                            HStack {
                                Image(systemName: "lock.fill")
                                
                                Text(String(localized: "private-club", table: "General"))
                                    .font(.callout)
                                Spacer()
                            }.frame(height: 20)
                            
                        } else {
                            HStack {
                                Image(systemName: "globe.americas.fill")
                                Text(String(localized: "public-club", table: "General"))
                                    .font(.callout)
                                Spacer()
                            }
                            .frame(height: 20)
                            .foregroundStyle(Color.foreground)
                        }
                        
                        HStack {
                            Text(String(localized: "\(club.members.count) member", table: "General"))
                                .font(.callout)
                            Spacer()
                        }
                        .foregroundStyle(Color.foreground)
                        
                    }
// Disabled until payments are working
//                    NavigationLink(destination: ClubWalletView().environment(club)) {
//                        Image(systemName: "wallet.bifold")
//                        Text("Wallet")
//                    }
//                    .padding(.horizontal)
//                    .padding(.vertical, 10)
//                    .modifier(BackgroundPillModifier())
                    
                }.padding(.all)
                
                VStack {
                    if role != "member" {
                        NavigationLink {
                            ClubEditor()
                                .environment(club)
                                .environment(session)
                        } label: {
                            MenuLabel(icon: Image(systemName: "pencil"), text: String(localized: "club-menu-edit-club", table: "Groups"))
                        }
                    }
                    
                    if role != "member" {
                        NavigationLink {
                            ClubApplications(club: club)
                        } label: {
                            MenuLabel(icon: Image(systemName: "note.text"), text: String(localized: "group-menu-applications", table: "Groups"))
                        }
                    }
                    
                    if role != "member" {
                        MenuButton(icon: Image(systemName: "ladybug"), text: String(localized: "group-menu-reports", table: "Groups"), action: {
                            self.showReports.toggle()
                        })
                    }
                    
                    if role != "member" {
                        MenuButton(icon: Image(systemName: "building.fill"), text: String(localized: "club-menu-change-organization", table: "Groups"), action: {
                            self.showOrganizations.toggle()
                        })
                    }
                    
                    NavigationLink {
                        NewClub(hideTopBar: true)
                    } label: {
                        MenuLabel(icon: Image(systemName: "plus.circle.fill"), text: String(localized: "club-menu-create-group", table: "Groups"), type: .normal)
                    }
                    
                    MenuButton(icon: Image(systemName: "magnifyingglass"), text: String(localized: "club-menu-search-clubs", table: "Groups"), action: {
                        self.showClubs.toggle()
                    })
                    
                    NavigationLink {
                        MembersListView()
                            .environment(club)
                    } label: {
                        MenuLabel(icon: Image(systemName: "person.3"), text: String(localized: "group-menu-members", table: "Groups"))
                    }
                    
                    if role != "owner" || (role == "owner" && !isOnlyOwner) {
                        MenuButton(icon: Image(systemName: "door.left.hand.open"), text: String(localized: "club-menu-leave-club", table: "Groups"), action: {
                            showAlert = false
                            alertType = .LeaveClub
                            showAlert.toggle()
                        }, type: .destructive)
                    }
                    
                    if role == "owner" {
                        MenuButton(icon: Image(systemName: "trash.fill"), text: String(localized: "club-menu-delete-club", table: "Groups"), action: {
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
                    return Alert(
                        title: Text(String(localized: "warning-leave-club-title", table: "Groups")),
                        message: Text(String(localized: "warning-leave-club-sub-title", table: "Groups")),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text(String(localized: "option-leave", table: "Groups")), action: {
                            Task { // Perform delete operation
                                _ = await session.clubObserver.leaveClub(id: club.id)
                                guard let selected = session.groupsManager.selected else { return }
                                session.clubsState = .loading
                                session.groupsManager.remove(selected)

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    session.clubsState = .success
                                    dismiss()
                                }
                            }
                        })
                    );
                case .DeleteClub:
                    return Alert(
                        title: Text(String(localized: "warning-delete-club-title", table: "Groups")),
                        message: Text(String(localized: "warning-delete-club-sub-title", table: "Groups")),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text(String(localized: "option-delete", table: "Groups")), action: {
                            Task { // Perform delete operation
                                _ = await session.clubObserver.deleteClub(id: club.id)
                                guard let selected = session.groupsManager.selected else { return }
                                session.clubsState = .loading
                                session.groupsManager.remove(selected)

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    session.clubsState = .success
                                    dismiss()
                                }
                            }
                        })
                    );
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        dismiss()
                    }
                }
        )
    }
}

#Preview {
    ClubMenu()
        .environment(CLUBS[0])
        .environment(SessionStore())
}
