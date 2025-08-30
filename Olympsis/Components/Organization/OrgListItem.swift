//
//  OrgListView.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import SwiftUI

struct OrgListItem: View {
    
    var organization: Organization
    @Binding var showToast: Bool
    @State var showActions: Bool = true
    @State private var status: LOADING_STATE = .pending
    @State private var showDetails: Bool = false
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
        guard let selectedGroup = session.groupsManager.selected,
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
            OrgListItemMedia(org: organization)
            
            HStack {
                VStack(alignment:.leading){
                    Text(name)
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color("foreground"))
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                        
                        Text(location)
                            .foregroundColor(.gray)
                    }
                    
                }
                .padding(.leading, 5)
            }
            .padding(.all)
            
            HStack {
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .lineLimit(nil)
                    .font(.callout)
            }
            .padding(.bottom)
            
            if showActions {
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
                    
                    Button(action:{ Task { await Apply() } }) {
                        LoadingButton(text: "Request", height: 35, status: $status)
                    }
                    .contentShape(Rectangle())
                }
                .padding([.horizontal, .bottom])
            }
        }
        .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(Color.Background.secondary))
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
