//
//  ClubMemberView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct ClubMemberView: View {
    
    @State var club: Club
    @State var member: Member
    @State private var showMenu = false
    @State private var clubObserver = ClubObserver()
    
    @EnvironmentObject var session:SessionStore
    
    func CheckRole() -> MEMBER_ROLES {
        if let usr = session.user {
            let mbr = club.members?.first(where: {$0.uuid == usr.uuid})
                if let m = mbr {
                    if m.role == "admin" {
                        return .Admin
                    } else if m.role == "moderator" {
                        return .Moderator
                    }
                }
        }
        return .Member
    }
    
    var body: some View {
        HStack {
            if let data = member.data {
                ZStack {
                    AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + (data.imageURL ?? ""))){ phase in
                        if let image = phase.image {
                                image // Displays the loaded image.
                                    .resizable()
                                    .clipShape(Circle())
                                    .scaledToFill()
                                    .clipped()
                            } else if phase.error != nil {
                                ZStack {
                                    Color.gray // Indicates an error.
                                        .clipShape(Circle())
                                    .opacity(0.3)
                                    Image(systemName: "exclamationmark.circle")
                                }
                            } else {
                                ZStack {
                                    Color.gray // Acts as a placeholder.
                                        .clipShape(Circle())
                                        .opacity(0.3)
                                    ProgressView()
                                }
                            }
                    }.frame(width: 50)
                }
            } else {
                ZStack {
                    Circle()
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                        .frame(width: 50)
                    .opacity(0.3)
                    Image(systemName: "exclamationmark.circle")
                }
            }
            
            VStack(alignment: .leading) {
                if let data = member.data {
                    Text(data.firstName! + " " + data.lastName!)
                    Text(data.username!)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Unknown User")
                    Text("olympsis-user")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            
            if member.role == "admin" {
                Image(systemName: "a.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(Color("tertiary-color"))
                    .padding(.trailing, 5)
            }
            if let usr = session.user {
                if usr.uuid == member.uuid {
                    EmptyView()
                } else {
                    Button(action:{self.showMenu.toggle()}){
                        Image(systemName: "ellipsis")
                            .imageScale(.large)
                            .foregroundColor(.primary)
                    }.padding(.trailing)
                        .sheet(isPresented: $showMenu) {
                            ClubMemberMenu(club: club, role: CheckRole(), member: member)
                                .presentationDetents([.height(250)])
                        }
                }
            } else {
                Button(action:{self.showMenu.toggle()}){
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }.padding(.trailing)
                    .sheet(isPresented: $showMenu) {
                        ClubMemberMenu(club: club, role: CheckRole(), member: member)
                            .presentationDetents([.height(250)])
                    }
            }

        }.padding(.leading)
            .frame(height: 60)
    }
}

struct ClubMemberView_Previews: PreviewProvider {
    static var previews: some View {
        ClubMemberView(club: CLUBS[0], member: (CLUBS[0].members?.first)!)
            .environmentObject(SessionStore())
    }
}
