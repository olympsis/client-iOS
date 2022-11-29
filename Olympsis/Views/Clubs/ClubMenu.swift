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
    @Binding var posts: [Post]
    
    @State private var showNewClub = false
    @State private var showApplications = false
    
    @StateObject private var clubObserver = ClubObserver()
    @StateObject private var postObserver = PostObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    AsyncImage(url: URL(string: club.imageURL)){ phase in
                        if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .scaledToFill()
                                .clipped()
                            
                        } else if phase.error != nil {
                            Color.red // Indicates an error.
                        } else {
                            Color.gray // Acts as a placeholder.
                        }
                    }.frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                        .padding(.top)
                    VStack {
                        if club.isPrivate {
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
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.gray)
                                            .opacity(0.3)
                                        HStack {
                                            Image(systemName: "note")
                                                .imageScale(.large)
                                                .padding(.leading)
                                                .foregroundColor(.black)
                                            Text("Club Applications")
                                                .foregroundColor(.black)
                                            Spacer()
                                        }
                                    }.frame(width: SCREEN_WIDTH-25, height: 50)
                                }.padding(.top)
                            }
                        }
                    }
                    
                    Button(action:{ }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                            HStack {
                                Image(systemName: "bell")
                                    .imageScale(.large)
                                    .padding(.leading)
                                    .foregroundColor(.black)
                                Text("Notifications")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }.frame(width: SCREEN_WIDTH-25, height: 50)
                    }
                    
                    Button(action:{ }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                            HStack {
                                Image(systemName: "arrow.3.trianglepath")
                                    .imageScale(.large)
                                    .padding(.leading)
                                    .foregroundColor(.black)
                                Menu("Switch Clubs") {
                                    ForEach(session.myClubs) { club in
                                        Button(action:{
                                            if let i = session.myClubs.firstIndex(where: { $0.id == club.id }) {
                                                index = i
                                                Task {
                                                    let _posts = await postObserver.fetchPosts(clubId: club.id)
                                                    posts = _posts
                                                }
                                                self.presentationMode.wrappedValue.dismiss()
                                            }
                                        }
                                        ){
                                            Text(club.name)
                                        }
                                    }
                                    
                                }.foregroundColor(.black)
                                Spacer()
                            }
                        }.frame(width: SCREEN_WIDTH-25, height: 50)
                    }
                    
                    Button(action:{ self.showNewClub.toggle() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                            HStack {
                                Image(systemName: "plus.diamond")
                                    .imageScale(.large)
                                    .padding(.leading)
                                    .foregroundColor(.black)
                                Text("Create a Club")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }.frame(width: SCREEN_WIDTH-25, height: 50)
                    }
                    
                    Button(action:{ }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                            HStack {
                                Image(systemName: "person.3")
                                    .imageScale(.large)
                                    .padding(.leading)
                                    .foregroundColor(.black)
                                Text("Members")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }.frame(width: SCREEN_WIDTH-25, height: 50)
                    }
                    
                    Button(action:{ }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                            HStack {
                                Image(systemName: "door.left.hand.open")
                                    .imageScale(.large)
                                    .padding(.leading)
                                    .foregroundColor(.red)
                                Text("Leave Club")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }.frame(width: SCREEN_WIDTH-25, height: 50)
                    }
                    
                    if let user = session.user {
                        if let member = club.members.first(where: {$0.uuid == user.uuid}) {
                            if member.role == "admin" {
                                Button(action:{ }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.gray)
                                            .opacity(0.3)
                                        HStack {
                                            Image(systemName: "trash.fill")
                                                .imageScale(.large)
                                                .padding(.leading)
                                                .foregroundColor(.red)
                                            Text("Delete Club")
                                                .foregroundColor(.red)
                                            Spacer()
                                        }
                                    }.frame(width: SCREEN_WIDTH-25, height: 50)
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
        }
    }
}

struct ClubMenu_Previews: PreviewProvider {
    static var previews: some View {
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/clubs/315204106_2320093024813897_5616555109943012779_n.jpg", isPrivate: false, isVisible: true, members: [Member(id: "0", uuid: "00", role: "admin", joinedAt: 0), Member(id: "1", uuid: "000", role: "admin", joinedAt: 0)], rules: ["No fighting"])
        ClubMenu(club: club, index: .constant(0), posts: .constant([Post]())).environmentObject(SessionStore())
    }
}
