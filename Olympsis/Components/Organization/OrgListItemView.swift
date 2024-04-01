//
//  OrgListView.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import SwiftUI

struct OrgListItemView: View {
    
    @State var organization: Organization
    
    @State private var status: LOADING_STATE = .pending
    @State private var showDetails: Bool = false
    @Binding var showToast: Bool
    @EnvironmentObject private var session: SessionStore
    
    var name: String {
        guard let name = organization.name else {
            return ""
        }
        return name
    }
    
    var imageURL: String {
        guard let img = organization.imageURL else {
            return GenerateImageURL("")
        }
        return GenerateImageURL(img)
    }
    
    var description: String {
        guard let str = organization.description else {
            return ""
        }
        return str
    }
    
    var sport: String {
        guard let s = organization.sport else {
            return "unknown"
        }
        return s
    }
    
    var location: String {
        guard let state = organization.state,
              let country = organization.country else {
            return "Unknown, World"
        }
        return state + ", " + country
    }
    
    func Apply() async {
        status = .loading
        guard let id = organization.id,
            let selectedGroup = session.selectedGroup,
              let clubID = selectedGroup.club?.id else {
            status = .failure
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                status = .pending
            }
            return
        }
        let app = OrganizationApplication(id: "", organizationID: id, clubID: clubID, status: "pending", data: nil, createdAt: 0)
        let res = await session.orgObserver.createOrganizationApplication(app: app)
        if res {
            status = .success
        } else {
            status = .failure
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                status = .pending
            }
        }
    }
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                // IMAGE
                if (organization.imageURL != nil) {
                    AsyncImage(url: URL(string: imageURL)){ phase in
                        if let image = phase.image {
                                image // Displays the loaded image.
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else if phase.error != nil {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .opacity(0.5)
                                        .frame(width: 100, height: 100)
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                }
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .opacity(0.5)
                                        .frame(width: 100, height: 100)
                                        .accentColor(Color("foreground"))
                                    ProgressView()
                                }
                            }
                    }.frame(width: 100, height: 100, alignment: .center)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.gray)
                            .opacity(0.5)
                            .frame(width: 100, height: 100)
                        Image(systemName: "building.fill")
                            .foregroundStyle(Color("foreground"))
                            .imageScale(.large)
                    }
                }
                
                VStack(alignment:.leading){
                    Text(name)
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color("foreground"))
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    Text(location)
                        .foregroundColor(.gray)
                }.padding(.leading, 5)
            }.padding(.all)
            
            HStack {
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .lineLimit(nil)
                    .font(.callout)
            }
            
            HStack {
                ClubTagView(isSport: true, tagName: sport)
            }.padding(.horizontal)
                .padding(.top)
            
            HStack(spacing: 15) {
                Button(action: { self.showDetails.toggle() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.gray)
                            .opacity(0.5)
                            .frame(height: 35)
                        Text("Details")
                            .foregroundStyle(Color("foreground"))
                    }
                }.contentShape(Rectangle())
                    .frame(width: (SCREEN_WIDTH/2)-25)
                
                Button(action:{ Task{ await Apply() } }) {
                    LoadingButton(text: "Request", width: (SCREEN_WIDTH/2)-25, height: 35, status: $status)
                }.contentShape(Rectangle())
            }.padding(.all)
        }.background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("background"))
                .padding(.horizontal, 5)
        }
        .fullScreenCover(isPresented: $showDetails, content: {
//            ClubView(club: club)
        })
    }
}

#Preview {
    OrgListItemView(organization: ORGANIZATIONS[1], showToast: .constant(false))
        .environmentObject(SessionStore())
}
