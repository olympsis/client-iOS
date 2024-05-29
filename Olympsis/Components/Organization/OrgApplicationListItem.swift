//
//  OrgApplicationView.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import SwiftUI

struct OrgApplicationListItem: View {
    
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
    
    var clubLocation: String {
        guard let club = application.data?.club,
              let city = club.city,
              let state = club.state else {
            return ""
        }
        return "\(city), \(state)"
    }
    
    var imageURL: String {
        guard let club = application.data?.club,
              let url = club.logo else {
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
        return Date(timeIntervalSince1970: TimeInterval(time)).formatted(.dateTime.day().month().year());
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
        VStack (alignment: .leading){
            HStack {
                AsyncImage(url: URL(string: imageURL)){ phase in
                    if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else if phase.error != nil {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10) // Indicates an error.
                                    .foregroundStyle(.gray)
                                    .opacity(0.5)
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(Color("foreground"))
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10) // Acts as a placeholder.
                                    .foregroundStyle(.gray)
                                    .opacity(0.5)
                                ProgressView()
                            }
                        }
                }.frame(width: 100, height: 100)
                    .padding(.all)
                
                VStack (alignment: .leading){
                    Text(clubName)
                        .font(.headline)
                    Text(clubLocation)
                        .foregroundStyle(.gray)
                }
            }
            
            HStack {
                Text(clubDescription)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .lineLimit(nil)
            }.padding(.bottom)
            
            HStack {
                Text("Created at:")
                    .font(.caption)
                    .bold()
                Text(dateTimeInString)
                    .font(.caption)
            }.padding(.leading)
                .padding(.bottom)
            
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
                }.frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35)
                    .padding(.leading)
            }.padding(.horizontal)
                .padding(.bottom, 20)
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("background"))
                .padding(.horizontal, 5)
        }
    }
}

#Preview {
    OrgApplicationListItem(application: ORGANIZATION_APPLICATIONS[0], applications: .constant(ORGANIZATION_APPLICATIONS))
        .environmentObject(SessionStore())
}
