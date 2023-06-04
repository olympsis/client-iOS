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
    
    var dateTimeInString: String {
        return "Created at: " + Date(timeIntervalSince1970: TimeInterval(application.createdAt)).formatted(.dateTime.day().month().year());
    }
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
                VStack (alignment: .leading){
                    HStack {
                        AsyncImage(url: URL(string: GenerateImageURL((application.data?.imageURL ?? "")))){ phase in
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
                        }.frame(width: 60, height: 60)
                            .padding(.leading, 5)
                        VStack (alignment: .leading){
                            Text(fullName)
                                .font(.headline)
                            Text(username)
                                .font(.body)
                                .foregroundColor(.gray)
                            Text(dateTimeInString)
                                .font(.callout)
                        }.padding(.leading, 5)
                    }.padding(.top, 5)

                    
                    HStack {
                        Spacer()
                        Button(action:{
                            Task {
                                await accept()
                            }
                        }){
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("primary-color"))
                                Text("accept")
                                    .foregroundColor(.white)
                            }
                        }.frame(width: 100, height: 40)
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
                            }
                        }.frame(width: 100, height: 40)
                            .padding(.trailing, 5)
                    }.padding(.bottom, 5)
                }.frame(width: SCREEN_WIDTH-25)
            }
        }.frame(width: SCREEN_WIDTH-20, height: 130)
    }
}

struct ClubApplicationView_Previews: PreviewProvider {
    static var previews: some View {
        ClubApplicationView(club: CLUBS[0], application: CLUB_APPLICATIONS[0], applications: .constant([ClubApplication]()))
    }
}
