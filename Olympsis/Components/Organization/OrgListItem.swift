//
//  OrgListView.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import SwiftUI

struct OrgListItem: View {
    
    @State var organization: Organization
    
    @State private var status: LOADING_STATE = .pending
    @State private var showDetails: Bool = false
    @Binding var showToast: Bool
    @Environment(SessionStore.self) private var session
    
    var name: String {
        return organization.name
    }
    
    var description: String {
        guard let str = organization.description else {
            return ""
        }
        return str
    }
    
    var sports: [String] {
        return organization.sports
    }
    
    var location: String {
        return organization.state + ", " + organization.country
    }
    
    func Apply() async {
        status = .loading
        guard let selectedGroup = session.selectedGroup,
              let clubID = selectedGroup.club?.id else {
            status = .failure
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                status = .pending
            }
            return
        }
        let app = OrganizationApplicationDao(organizationID: organization.id, clubID: clubID, status: "pending")
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
                
                OrgLogo(organization: organization)
                
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
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(sports, id: \.self) { sport in
                        ClubTag(isSport: true, tagName: sport)
                    }
                }
            }
            .padding(.horizontal)
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
                }
                .contentShape(Rectangle())
                .frame(width: (SCREEN_WIDTH/2)-25)
                
                Button(action:{ Task { await Apply() } }) {
                    LoadingButton(text: "Request", width: (SCREEN_WIDTH/2)-25, height: 35, status: $status)
                }.contentShape(Rectangle())
            }.padding(.all)
        }.background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(Color.Background.secondary))
                .padding(.horizontal, 5)
        }
        .fullScreenCover(isPresented: $showDetails, content: {
            OrgDetailView(organization: organization)
        })
    }
}

#Preview {
    OrgListItem(organization: ORGANIZATIONS[1], showToast: .constant(false))
        .environment(SessionStore())
}
