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
    
    @State var club: Club
    
    @State private var showAlert = false
    @State private var showOrganizations = false
    @State private var showClubs = false
    @State private var showNewClub = false
    @State private var showMembers = false
    @State private var showApplications = false
    @State private var showLeaveClubAlert = false
    @State private var showDeleteClubAlert = false
    
    @State private var alertType = Alerts.LeaveClub
    
    @StateObject private var clubObserver = ClubObserver()
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var role: String {
        guard let user = session.user,
              let members = club.members,
            let member = members.first(where: {$0.uuid == user.uuid}) else {
            return "member"
        }
        return member.role
    }
    
    // this will be handled in the backend as well
    var isOnlyOwner: Bool {
        guard let members = club.members else {
            return false
        }
        let owners = members.filter({ $0.role == "owner" })
        return owners.count < 2
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    AsyncImage(url: URL(string: GenerateImageURL(club.imageURL ?? ""))){ phase in
                        if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .scaledToFill()
                                .frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                                .clipped()
                        } else if phase.error != nil {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground) )
                                    .opacity(0.3)
                                    .frame(width: SCREEN_WIDTH-10, height: 300, alignment: .center)
                                Image(systemName: "exclamationmark.circle")
                            }
                        } else {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground) )
                                    .opacity(0.3)
                                    .frame(width: SCREEN_WIDTH-10, height: 300, alignment: .center)
                                ProgressView()
                            }
                        }
                    }.frame(width: SCREEN_WIDTH-10, height: 300, alignment: .center)
                        .padding(.top)
                        
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
                                    .foregroundStyle(Color("color-prime"))
                                Text("Public group")
                                    .font(.callout)
                                Spacer()
                            }.frame(height: 20)
                        }
                        
                        HStack {
                            Text("\(club.members!.count)").foregroundColor(Color("color-prime")) +
                            Text(" members")
                                .font(.callout)
                            Spacer()
                        }
                        
                    }.padding(.vertical)
                        .padding(.horizontal)
                    
                    VStack {
                        if role != "member" {
                            MenuButton(icon: Image(systemName: "note.text"), text: "Applications", action: {
                                self.showApplications.toggle()
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
                        
                        MenuButton(icon: Image(systemName: "person.3"), text: "Members", action: {
                            self.showMembers.toggle()
                        })
                        
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
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("color-prime"))
                    }
                }
            }
            .navigationTitle(club.name ?? "Clubs")
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
            .fullScreenCover(isPresented: $showMembers) {
                MembersListView(club: club)
            }
            .fullScreenCover(isPresented: $showClubs) {
                ClubsList2()
            }
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
                                        guard let id = club.id else {
                                            return
                                        }
                                        _ = await session.clubObserver.leaveClub(id: id)
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
                                    guard let id = club.id else {
                                        return
                                    }
                                    _ = await session.clubObserver.leaveClub(id: id)
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
                                guard let id = club.id else {
                                    return
                                }
                                _ = await session.clubObserver.deleteClub(id: id)
                            }
                        })
                    );
                }
            }
        }
    }
}

struct ClubMenu_Previews: PreviewProvider {
    static var previews: some View {
        ClubMenu(club: CLUBS[0]).environmentObject(SessionStore())
    }
}
