//
//  ClubMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct ClubMenu: View {
    
    @State var club: Club
    @Binding var index: Int
    
    @State private var showClubs = false
    @State private var showNewClub = false
    @State private var showMembers = false
    @State private var showApplications = false
    
    @StateObject private var clubObserver = ClubObserver()
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + (club.imageURL ?? ""))){ phase in
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
                        if club.isPrivate ?? false {
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
                            Text("\(club.members.count)") +
                            Text(" members")
                            Spacer()
                        }.padding(.leading)
                        
                    }
                    
                    if let user = session.user {
                        if let member = club.members.first(where: {$0.uuid == user.uuid}) {
                            if member.role == "admin" {
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
                        }
                    }

                    Menu {
                        ForEach(session.myClubs) { club in
                            Button(action:{
                                if let i = session.myClubs.firstIndex(where: { $0.id == club.id }) {
                                    index = i
                                }
                            }
                            ){
                                Text(club.name)
                            }
                        }
                    }label: {
                        HStack {
                            Image(systemName: "arrow.3.trianglepath")
                                .imageScale(.large)
                                .padding(.leading)
                            .foregroundColor(.primary)
                            Text("Switch Club")
                            Spacer()
                        }
                    }.foregroundColor(.primary)
                    .frame(width: SCREEN_WIDTH-25, height: 50)
                    .modifier(MenuButton())
                            
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
                    
                    Button(action:{ }) {
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
                    
                    if let user = session.user {
                        if let member = club.members.first(where: {$0.uuid == user.uuid}) {
                            if member.role == "admin" {
                                Button(action:{ }) {
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
                    }
                    
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("primary-color"))
                    }
                }
            }
            .navigationTitle(club.name)
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showNewClub) {
                CreateNewClub()
            }
            .fullScreenCover(isPresented: $showApplications) {
                ClubApplications(club: club)
            }
            .fullScreenCover(isPresented: $showClubs) {
                ClubsList2()
            }
        }
    }
}

struct ClubMenu_Previews: PreviewProvider {
    static var previews: some View {
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "clubs/308973276_8080928561980330_1395494675708418495_n.jpg", isPrivate: false, members: [Member(id: "0", uuid: "00", role: "admin", data: nil, joinedAt: 0), Member(id: "1", uuid: "000", role: "admin", data: nil, joinedAt: 0)], rules: ["No fighting"], createdAt: 0)
        ClubMenu(club: club, index: .constant(0)).environmentObject(SessionStore())
    }
}
