//
//  ClubMemberView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct MemberView: View {
    
    @State var club: Club
    @State var member: Member
    @State private var showMenu = false
    @EnvironmentObject var session:SessionStore
    
    var fullName: String {
        guard let data = member.data,
              let firstName = data.firstName,
              let lastName = data.lastName else {
            return "Olympsis User"
        }
        return firstName + " " + lastName;
    }
    
    var username: String {
        guard let data = member.data, let username = data.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var userRole: String {
        guard let user = session.user,
              let members = club.members,
              let member = members.first(where: {$0.uuid == user.uuid}) else {
            return "member"
        }
        return member.role
    }
    
    var memberIsUser: Bool {
        guard let user = session.user, let uuid = user.uuid else {
            return false
        }
        return uuid == member.uuid
    }
    
    var body: some View {
        HStack {
            ZStack {
                AsyncImage(url: URL(string: GenerateImageURL((member.data?.imageURL ?? "")))){ phase in
                    if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 50)
                                .scaledToFill()
                                .clipped()
                        } else if phase.error != nil {
                            ZStack {
                                Color.gray // Indicates an error.
                                    .clipShape(Circle())
                                .opacity(0.3)
                                Image(systemName: "person")
                                    .foregroundStyle(.white)
                                    .imageScale(.large)
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
            
            VStack(alignment: .leading) {
                Text(fullName)
                Text(username)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            switch member.role {
            case "owner":
                Image(systemName: "o.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.yellow)
                    .padding(.trailing, 5)
            case "admin":
                Image(systemName: "a.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(Color("tertiary-color"))
                    .padding(.trailing, 5)
            case "moderator":
                Image(systemName: "a.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.orange)
                    .padding(.trailing, 5)
            default:
                EmptyView()
            }
            
            if !memberIsUser {
                Button(action:{self.showMenu.toggle()}){
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }.padding(.trailing)
                    .sheet(isPresented: $showMenu) {
                        ClubMemberMenu(club: club, role: userRole, member: member)
                            .presentationDetents([.height(250)])
                    }
            }
        }.padding(.leading)
            .frame(height: 60)
    }
}

struct ClubMemberView_Previews: PreviewProvider {
    static var previews: some View {
        MemberView(club: CLUBS[0], member: (CLUBS[0].members?.first)!)
            .environmentObject(SessionStore())
    }
}
