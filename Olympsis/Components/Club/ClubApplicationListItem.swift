//
//  ClubApplicationView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct ClubApplicationListItem: View {
    
    @State var club: Club
    @State var application: ClubApplication
    @Binding var applications: [ClubApplication]
    @Environment(SessionStore.self) private var session
    
    var fullName: String {
        guard let data = application.applicant,
              let firstName = data.firstName,
              let lastName = data.lastName else {
            return "Olympsis User"
        }
        return firstName + " " + lastName;
    }
    
    var username: String {
        guard let data = application.applicant,
              let username = data.username else {
            return "olympsis-user"
        }
        return "\(username)";
    }
    
    var userBio: String {
        guard let data = application.applicant,
              let bio = data.bio else {
                  return "..."
              }
        return bio;
    }
    
    var userImageURL: URL? {
        guard let data = application.applicant,
              let imageURL = data.imageURL else {
            return nil
        }
        return URL(string: GenerateImageURL(imageURL))
    }
    
    var dateTimeInString: String {
        return application.createdAt.formatted(.dateTime.day().month().year());
    }
    
    func accept() async {
        let req = ApplicationUpdateRequest(status: "accepted")
        let res = await session.clubObserver.updateApplication(id: club.id, appID: application.id, req: req)
        if res {
            withAnimation(.easeOut){
                self.applications.removeAll(where: {$0.id == application.id})
            }
        }
    }
    
    func deny() async {
        let req = ApplicationUpdateRequest(status: "denied")
        let res = await session.clubObserver.updateApplication(id: club.id, appID: application.id, req: req)
        if res {
            withAnimation(.easeOut){
                self.applications.removeAll(where: {$0.id == application.id})
            }
        }
    }
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                UserBadgeView(size: .large, imageURL: userImageURL)
                    .padding(.vertical)
                    .padding(.leading)
                    .padding(.trailing, 10)
                
                VStack (alignment: .leading){
                    Text(fullName)
                        .font(.headline)
                    Text(username)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Text(userBio)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .lineLimit(nil)
            }.padding(.bottom)
            
            HStack {
                Text("Created at:")
                    .font(.caption)
                    .fontWeight(.bold)
                Text(dateTimeInString)
                    .font(.caption)
                    .italic()
            }.padding([.leading, .bottom])
            
            HStack {
                Button(action:{
                    Task {
                        await accept()
                    }
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("color-prime"))
                        Text("accept")
                            .foregroundColor(.white)
                            .font(.caption)
                            .textCase(.uppercase)
                    }
                }.frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35)
                    .padding(.trailing)
                Button(action:{
                    Task {
                        await deny()
                    }
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.red)
                        Text("deny")
                            .foregroundColor(.white)
                            .font(.caption)
                            .textCase(.uppercase)
                    }
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35)
                    
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }.background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color(Color.Background.secondary))
                .padding(.horizontal, 5)
        }
    }
}

#Preview {
    ClubApplicationListItem(club: CLUBS[0], application: CLUB_APPLICATIONS[0], applications: .constant([ClubApplication]()))
        .environment(SessionStore())
}
