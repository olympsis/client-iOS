//
//  Clubs.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI
import AlertToast

struct Clubs: View {
    
    @State private var index: Int = 0
    @State private var posts = [Post]()
    @State private var showMenu: Bool = false
    @State private var showMessages: Bool = false
    @State private var status: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        NavigationView {
            VStack {
                if status == .loading {
                    ClubLoadingTemplateView()
                } else {
                    if $session.myClubs.isEmpty {
                        ClubsList()
                            .sheet(isPresented: $showMenu) {
                                NoClubMenu()
                                    .presentationDetents([.height(250)])
                            }
                    } else {
                        MyClubView(club: $session.myClubs[index])
                            .fullScreenCover(isPresented: $showMenu) {
                                ClubMenu(club: session.myClubs[index], index: $index)
                            }
                            .fullScreenCover(isPresented: $showMessages) {
                                Messages(club: session.myClubs[index])
                            }
                    }
                }
                
            }.toolbar {
                if status == .loading {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Rectangle()
                            .foregroundColor(.gray)
                            .frame(width: 150, height: 30)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing){
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                } else {
                    if session.myClubs.isEmpty {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("Clubs")
                                .font(.largeTitle)
                                .bold()
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button(action:{ self.showMenu.toggle() }) {
                                Image(systemName: "c.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text(session.myClubs[index].name)
                                .font(.title)
                                .bold()
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action:{self.showMessages.toggle()}){
                                Image(systemName: "bubble.right")
                                    .foregroundColor(Color("primary-color"))
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action:{ self.showMenu.toggle() }) {
                                AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + (session.myClubs[index].imageURL ?? ""))){ image in
                                    image.resizable()
                                        .clipShape(Circle())
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                        
                                } placeholder: {
                                    Circle()
                                        .foregroundColor(.gray)
                                        .opacity(0.3)
                                        .frame(width: 30)
                                }
                            }
                        }
                    }
                }
            }
            .task {
                if session.myClubs.isEmpty {
                    if let usr = session.user {
                        if let myClubs = usr.clubs {
                            if !myClubs.isEmpty {
                                // this checks to see if we failed to get club data then we try again
                                status = .loading
                                await session.generateClubsData()
                                status = .success
                            }
                        }
                    }
                }
            }
        }
    }
}

struct Clubs_Previews: PreviewProvider {
    static var previews: some View {
        Clubs().environmentObject(SessionStore())
    }
}
