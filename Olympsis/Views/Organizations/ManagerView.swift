//
//  ManagerView.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import SwiftUI

struct ManagerView: View {
    
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
                                .scaledToFill()
                                .clipped()
                        } else if phase.error != nil {
                            ZStack {
                                Color.gray // Indicates an error.
                                    .clipShape(Circle())
                                .opacity(0.3)
                                .frame(width: 45, height: 45)
                                Image(systemName: "exclamationmark.circle")
                            }
                        } else {
                            ZStack {
                                Color.gray // Acts as a placeholder.
                                    .clipShape(Circle())
                                    .opacity(0.3)
                                    .frame(width: 45, height: 45)
                                ProgressView()
                            }
                        }
                }.frame(width: 45, height: 45)
            }
            
            VStack(alignment: .leading) {
                Text(fullName)
                Text(username)
                    .font(.callout)
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
        }.padding(.leading)
            .frame(height: 60)
    }
}

#Preview {
    ManagerView(member: CLUBS[0].members!.first!)
}
