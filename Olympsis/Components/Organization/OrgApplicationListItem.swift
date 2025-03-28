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
    @Environment(SessionStore.self) private var session
    
    var clubName: String {
        guard let club = application.club else {
            return "club_name"
        }
        return club.name
    }
    
    var clubLocation: String {
        guard let club = application.club else {
            return ""
        }
        return "\(club.city), \(club.state)"
    }
    
    var imageURL: String {
        guard let club = application.club,
              let url = club.logo else {
            return GenerateImageURL("")
        }
        return GenerateImageURL(url)
    }
    
    var clubDescription: String {
        guard let club = application.club,
              let description = club.description else {
            return "..."
        }
        return description
    }
    
    var dateTimeInString: String {
        guard let club = application.club else {
            return "Created at: unknown"
        }
        return club.createdAt.formatted(.dateTime.day().month().year());
    }
    
    func accept() async {
        guard let org = session.selectedGroup?.organization,
            let club = application.club else {
            return
        }
        let dto = OrganizationApplicationDao(organizationID: "\(org.id ?? "")", clubID: "\(club.id)", status: "accepted")
        let res = await session.orgObserver.updateApplication(id: application.id, app: dto)
        if res {
            withAnimation(.easeOut){
                self.applications.removeAll(where: {$0.id == application.id})
            }
        }
    }
    
    func deny() async {
        guard let org = session.selectedGroup?.organization,
            let club = application.club else {
            return
        }
        let dto = OrganizationApplicationDao(organizationID: "\(org.id ?? "")", clubID: "\(club.id)", status: "denied")
        let res = await session.orgObserver.updateApplication(id: application.id, app: dto)
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
                .foregroundStyle(Color(Color.Background.secondary))
                .padding(.horizontal, 5)
        }
    }
}

#Preview {
    OrgApplicationListItem(application: ORGANIZATION_APPLICATIONS[0], applications: .constant(ORGANIZATION_APPLICATIONS))
        .environment(SessionStore())
}
