//
//  ClubMemberView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct MemberView2: View {
    
    @State var member: UserSnippet
    @State private var showMenu = false
    @EnvironmentObject var session:SessionStore
    
    var username: String {
        guard let username = member.username else {
            return "olympsis-user"
        }
        return username
    }
    
    var body: some View {
        HStack {
            ZStack {
                AsyncImage(url: URL(string: GenerateImageURL((member.imageURL ?? "")))){ phase in
                    if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .clipShape(Circle())
                                .scaledToFill()
                                .frame(width: 50)
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
                Text(username)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }.padding(.leading)
            .frame(height: 60)
    }
}

struct ClubMemberView2_Previews: PreviewProvider {
    static var previews: some View {
        MemberView2(member: USER_SNIPPETS[0])
            .environmentObject(SessionStore())
    }
}
