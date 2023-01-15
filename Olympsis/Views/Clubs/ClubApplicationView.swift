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
    @StateObject private var observer = ClubObserver()
    
    func accept() async {
        let dao = UpdateApplicationDao(_clubId: club.id, _status: "accepted")
        let res = await observer.updateApplication(id: club.id, appId: application.id, dao: dao)
        if res {
            withAnimation(.easeOut){
                self.applications.removeAll(where: {$0.id == application.id})
            }
        }
    }
    
    func deny() async {
        let dao = UpdateApplicationDao(_clubId: club.id, _status: "denied")
        let res = await observer.updateApplication(id: club.id, appId: application.id, dao: dao)
        if res {
            withAnimation(.easeOut){
                self.applications.removeAll(where: {$0.id == application.id})
            }
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
                VStack (alignment: .leading){
                    HStack {
                        AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + (application.data.imageURL ?? ""))){ phase in
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
                            Text(application.data.firstName)
                                .font(.headline)
                            +
                            Text(" \(application.data.lastName)")
                                .font(.headline)
                            Text("@\(application.data.username)")
                                .font(.body)
                                .foregroundColor(.gray)
                            Text("Created at:")
                                .font(.callout)
                            +
                            Text(" \(Date(timeIntervalSince1970: TimeInterval(application.createdAt)).formatted(.dateTime.day().month().year()))")
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
        let app = ClubApplication(id: "", uuid: "", data: UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "profile-images/62D674D2-59D2-4095-952B-4CE6F55F681F", bio: "", sports: ["soccer","tennis"], badges: [Badge](), trophies: [Trophy](), friends: [Friend]()), status: "pending", createdAt: 1669245600)
        let club = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/clubs/315204106_2320093024813897_5616555109943012779_n.jpg", isPrivate: false, members: [Member(id: "", uuid: "00", role: "admin", data: nil, joinedAt: 0), Member(id: "1", uuid: "000", role: "admin", data: nil, joinedAt: 0)], rules: ["No fighting"], createdAt: 0)
        ClubApplicationView(club: club, application: app, applications: .constant([ClubApplication]()))
    }
}
