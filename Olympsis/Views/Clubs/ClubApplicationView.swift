//
//  ClubApplicationView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct ClubApplicationView: View {
    
    @State var club: Club
    @State var application: ClubApplication
    @Binding var applications: [ClubApplication]
    @EnvironmentObject var session: SessionStore
    
    var fullName: String {
        guard let data = application.data,
              let firstName = data.firstName,
              let lastName = data.lastName else {
            return "Olympsis User"
        }
        return firstName + " " + lastName;
    }
    
    var username: String {
        guard let data = application.data,
              let username = data.username else {
            return "@olympsis-user"
        }
        return "@\(username)";
    }
    
    var userBio: String {
        guard let data = application.data,
              let bio = data.bio else {
                  return "..."
              }
        return bio;
    }
    
    var userImageURL: String {
        guard let data = application.data,
              let imageURL = data.imageURL else {
            return ""
        }
        return GenerateImageURL(imageURL)
    }
    
    var dateTimeInString: String {
        return "Created at: " + Date(timeIntervalSince1970: TimeInterval(application.createdAt)).formatted(.dateTime.day().month().year());
    }
    
    func accept() async {
        guard let id = club.id else {
            return
        }
        let req = ApplicationUpdateRequest(status: "accepted")
        let res = await session.clubObserver.updateApplication(id: id, appID: application.id, req: req)
        if res {
            withAnimation(.easeOut){
                self.applications.removeAll(where: {$0.id == application.id})
            }
        }
    }
    
    func deny() async {
        guard let id = club.id else {
            return
        }
        let req = ApplicationUpdateRequest(status: "denied")
        let res = await session.clubObserver.updateApplication(id: id, appID: application.id, req: req)
        if res {
            withAnimation(.easeOut){
                self.applications.removeAll(where: {$0.id == application.id})
            }
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("background"))
                VStack (alignment: .leading){
                    HStack {
                        AsyncImage(url: URL(string: userImageURL)){ phase in
                            if let image = phase.image {
                                    image // Displays the loaded image.
                                        .resizable()
                                        .clipShape(Circle())
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                } else if phase.error != nil {
                                    ZStack {
                                        Color.gray // Indicates an error.
                                            .clipShape(Circle())
                                        .opacity(0.3)
                                        Image(systemName: "exclamationmark.circle")
                                            .foregroundColor(Color("foreground"))
                                    }
                                } else {
                                    ZStack {
                                        Color.gray // Acts as a placeholder.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                        ProgressView()
                                    }
                                }
                        }.frame(width: 100, height: 100)
                            .padding(.all)
                        VStack (alignment: .leading){
                            Text(fullName)
                                .font(.headline)
                            Text(username)
                                .font(.body)
                                .foregroundColor(.gray)
                            Text(dateTimeInString)
                                .font(.callout)
                                .italic()
                        }
                    }
                    
                    HStack {
                        Text(userBio)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal)
                            .lineLimit(nil)
                    }.padding(.bottom)
                    
                    HStack {
                        Button(action:{
                            Task {
                                await accept()
                            }
                        }){
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(Color("color-prime"))
                                Text("accept")
                                    .foregroundColor(.white)
                            }
                        }.frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                            .padding(.trailing)
                        Button(action:{
                            Task {
                                await deny()
                            }
                        }){
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(.red)
                                Text("deny")
                                    .foregroundColor(.white)
                            }
                        }.frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                            .padding(.leading)
                    }.padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
        }.padding(.horizontal, 5)
    }
}

struct ClubApplicationView_Previews: PreviewProvider {
    static var previews: some View {
        ClubApplicationView(club: CLUBS[0], application: CLUB_APPLICATIONS[0], applications: .constant([ClubApplication]()))
    }
}
