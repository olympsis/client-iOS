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
    
    @Binding var club: Club
    @Binding var index: Int
    
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
                                .cornerRadius(10)
                        } else if phase.error != nil {
                            ZStack {
                                Color(uiColor: .tertiarySystemGroupedBackground)
                                    .cornerRadius(10)
                                Image(systemName: "exclamationmark.circle")
                            } // Indicates an error.
                        } else {
                            ZStack {
                                Color(uiColor: .tertiarySystemGroupedBackground) // Acts as a placeholder.
                                    .opacity(0.3)
                                    .cornerRadius(10)
                                ProgressView()
                            }
                        }
                    }.frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                        .padding(.top)
                    VStack {
                        if club.visibility == "private" {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Private group")
                                Spacer()
                            }.frame(height: 20)
                                .padding(.leading)
                                .padding(.top)
                        } else {
                            HStack {
                                Image(systemName: "globe.americas.fill")
                                Text("Public group")
                                Spacer()
                            }.frame(height: 20)
                                .padding(.leading)
                                .padding(.top)
                        }
                        
                        HStack {
                            Text("\(club.members!.count)") +
                            Text(" members")
                            Spacer()
                        }.padding(.leading)
                        
                    }
                    
                    if role != "member" {
                        Button(action:{ self.showApplications.toggle() }) {
                            HStack {
                                Image(systemName: "note")
                                    .imageScale(.large)
                                    .padding(.leading)
                                    .foregroundColor(.primary)
                                Text("Club Applications")
                                    .foregroundColor(.primary)
                                Spacer()
                            }.modifier(MenuButton())
                        }.padding(.top)
                    }
                            
                    Button(action:{ self.showNewClub.toggle() }) {
                        HStack {
                            Image(systemName: "plus.diamond")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Create a Club")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    Button(action:{ self.showClubs.toggle() }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .imageScale(.large)
                                .padding(.leading)
                                .foregroundColor(.primary)
                            Text("Search Clubs")
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
                            Text("Members")
                                .foregroundColor(.primary)
                            Spacer()
                        }.modifier(MenuButton())
                    }.fullScreenCover(isPresented: $showMembers) {
                        MembersListView(club: club)
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
                            Text("Leave Club")
                                .foregroundColor(.red)
                            Spacer()
                        }.modifier(MenuButton())
                    }
                    
                    if role == "owner" {
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
                                Text("Delete Club")
                                    .foregroundColor(.red)
                                Spacer()
                            }.modifier(MenuButton())
                        }
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
            .navigationTitle(club.name ?? "Clubs")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showNewClub) {
                NewGroup()
            }
            .fullScreenCover(isPresented: $showApplications) {
                ClubApplications(club: club)
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
                            title: Text("Leaving Club"),
                            message: Text("Are you sure you want to leave this club?"),
                            primaryButton: .cancel(),
                            secondaryButton: .destructive(Text("Leave"), action: {
                                Task { // Perform delete operation
                                    guard let id = club.id else {
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
                        title: Text("Delete Club"),
                        message: Text("Are you sure you want to delete this club?"),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Delete"), action: {
                            Task { // Perform delete operation
                                guard let id = club.id else {
                                    return
                                }
                                let res = await session.clubObserver.deleteClub(id: id)
                                if res {
                                    let _ = await session.generateUserData()
                                    session.clubs.removeAll(where: { $0.id == id })
                                    self.presentationMode.wrappedValue.dismiss()
                                }
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
        ClubMenu(club: .constant(CLUBS[0]), index: .constant(0)).environmentObject(SessionStore())
    }
}
