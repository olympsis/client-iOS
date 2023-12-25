//
//  OrgMenu.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import SwiftUI

struct OrgMenu: View {
    
    enum Alerts {
        case LeaveClub
        case DeleteClub
    }
    
    @State var organization: Organization
    
    @State private var showAlert = false
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
              let members = organization.members,
            let member = members.first(where: {$0.uuid == user.uuid}) else {
            return "member"
        }
        return member.role
    }
    
    // this will be handled in the backend as well
    var isOnlyOwner: Bool {
        guard let members = organization.members else {
            return false
        }
        let owners = members.filter({ $0.role == "owner" })
        return owners.count < 2
    }
    
    var name: String {
        guard let orgName = organization.name else {
            return "Organization"
        }
        return orgName
    }
    
    var imageURL: String {
        guard let url = organization.imageURL else {
            return GenerateImageURL("")
        }
        return GenerateImageURL(url)
    }
    
    var members: [Member] {
        guard let members = organization.members else {
            return [Member]()
        }
        return members
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    AsyncImage(url: URL(string: imageURL)){ phase in
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
                                    .frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                                Image(systemName: "exclamationmark.circle")
                            }
                        } else {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground) )
                                    .opacity(0.3)
                                    .frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                                ProgressView()
                            }
                        }
                    }.frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                        
                    VStack {
                        HStack {
                            Image(systemName: "building.fill")
                                .foregroundStyle(Color("color-prime"))
                            Text("Organization")
                                .font(.callout)
                            Spacer()
                        }.frame(height: 20)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        HStack {
                            Text("\(members.count)").foregroundColor(Color("color-prime"))
                            if (members.count > 1) {
                                Text("managers")
                                    .font(.callout)
                            } else {
                                Text("manager")
                                    .font(.callout)
                            }
                            Spacer()
                        }.padding(.leading)
                        
                    }
                    
                    Button(action:{ self.showApplications.toggle() }) {
                        HStack {
                            Image(systemName: "note")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Applications")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }.padding(.top)
                            
                    Button(action:{ self.showNewClub.toggle() }) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Create a New Group")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    Button(action:{ self.showMembers.toggle() }) {
                        HStack {
                            Image(systemName: "person.3")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Managers")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    Button(action:{
                        showAlert = false
                        alertType = .LeaveClub
                        showAlert.toggle()
                    }) {
                        HStack {
                            Image(systemName: "door.left.hand.open")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.red)
                            Text("Leave Organization")
                                .foregroundColor(.red)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    Button(action:{
                        showAlert = false
                        alertType = .DeleteClub
                        showAlert.toggle()
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.red)
                            Text("Delete Organization")
                                .foregroundColor(.red)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("color-prime"))
                    }
                }
            }
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showNewClub) {
                NewGroup()
            }
            .fullScreenCover(isPresented: $showApplications) {
                    OrgApplications()
            }
            .fullScreenCover(isPresented: $showMembers) {
                ManagersListView(organization: organization)
            }
            .alert(isPresented: $showAlert) {
                switch alertType {
                case .LeaveClub:
                    switch role {
                    case "owner":
                        if isOnlyOwner {
                            return Alert(
                                title: Text("About Leaving Organization"),
                                message: Text("You cannot leave this club. You are the only owner. Please delete the organization or appoint new owners."),
                                dismissButton: .default(Text("Ok"))
                            )
                        } else {
                            return Alert(
                                title: Text("Leaving Organization"),
                                message: Text("Are you sure you want to leave this organization?"),
                                primaryButton: .cancel(),
                                secondaryButton: .destructive(Text("Leave"), action: {
                                    Task { // Perform delete operation
                                        guard let id = organization.id else {
                                            return
                                        }
                                        let res = await session.clubObserver.leaveClub(id: id)
                                        if res {
                                            let _ = await session.generateUserData()
                                            session.clubs.removeAll(where: { $0.id == id })
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                })
                            );
                        }
                    default:
                        return Alert(
                            title: Text("Leaving Organization"),
                            message: Text("Are you sure you want to leave this organization?"),
                            primaryButton: .cancel(),
                            secondaryButton: .destructive(Text("Leave"), action: {
                                Task { // Perform delete operation
                                    guard let id = organization.id else {
                                        return
                                    }
                                    let res = await session.clubObserver.leaveClub(id: id)
                                    if res {
                                        let _ = await session.generateUserData()
                                        session.clubs.removeAll(where: { $0.id == id })
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            })
                        );
                    }
                case .DeleteClub:
                    return Alert(
                        title: Text("Delete Organization"),
                        message: Text("Are you sure you want to delete this organization? This action cannot be undone."),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Delete"), action: {
                            Task { // Perform delete operation
                                guard let id = organization.id else {
                                    return
                                }
                                let res = await session.orgObserver.deleteOrganization(id: id)
                                if res {
                                    session.selectedGroup = session.groups.first
                                    session.groups.removeAll(where: { $0.organization?.id == id })
                                }
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        })
                    );
                }
        }
        }
    }
}


#Preview {
    NavigationStack {
        OrgMenu(organization: ORGANIZATIONS[0])
            .environmentObject(SessionStore())
    }
}
