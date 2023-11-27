//
//  OrgApplicationView.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import SwiftUI

struct OrgApplicationView: View {
    
    @State var application: OrganizationApplication
    @Binding var applications: [OrganizationApplication]
    @EnvironmentObject private var session: SessionStore
    
    var clubName: String {
        guard let club = application.data?.club,
              let name = club.name else {
            return "club_name"
        }
        return name
    }
    
    var imageURL: String {
        guard let club = application.data?.club,
              let url = club.imageURL else {
            return GenerateImageURL("")
        }
        return GenerateImageURL(url)
    }
    
    var clubDescription: String {
        guard let club = application.data?.club,
              let description = club.description else {
            return "..."
        }
        return description
    }
    
    var dateTimeInString: String {
        guard let club = application.data?.club,
              let time = club.createdAt else {
            return "Created at: unknown"
        }
        return "Created at: " + Date(timeIntervalSince1970: TimeInterval(time)).formatted(.dateTime.day().month().year());
    }
    
    func accept() async {
        application.status = "accepted"
        let res = await session.orgObserver.updateApplication(id: application.id, app: application)
        if res {
            withAnimation(.easeOut){
                self.applications.removeAll(where: {$0.id == application.id})
            }
        }
    }
    
    func deny() async {
        application.status = "denied"
        let res = await session.orgObserver.updateApplication(id: application.id, app: application)
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
                        AsyncImage(url: URL(string: imageURL)){ phase in
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
                            Text(clubName)
                                .font(.headline)
                            Text(dateTimeInString)
                                .font(.callout)
                                .italic()
                        }
                    }
                    
                    HStack {
                        Text(clubDescription)
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

#Preview {
    OrgApplicationView(application: ORGANIZATION_APPLICATIONS[0], applications: .constant(ORGANIZATION_APPLICATIONS))
        .environmentObject(SessionStore())
}
