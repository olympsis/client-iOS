//
//  OrgApplications.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import SwiftUI

struct OrgApplications: View {
    
    @State var applications = [OrganizationApplication]()
    @Environment(SessionStore.self) private var session
    @Environment(\.presentationMode) var presentationMode
    
    var organizationID: String {
        guard let selectedGroup = session.selectedGroup,
              let organization = selectedGroup.organization,
              let id = organization.id else {
            return ""
        }
        return id
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    if applications.filter({$0.status != "accepted"}).count > 0 {
                        ForEach(applications.filter({$0.status != "accepted"})) { application in
                            OrgApplicationListItem(application: application, applications: $applications)
                        }
                    } else {
                        Text("No Applications")
                    }
                    
                }.refreshable {
                    let res = await session.orgObserver.getApplications(id: organizationID)
                    await MainActor.run {
                        applications = res
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("color-prime"))
                    }
                }
            }
            .background(Color("background-color/primary"))
            .navigationTitle("Applications")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                let res = await session.orgObserver.getApplications(id: organizationID)
                await MainActor.run {
                    applications = res
                }
            }
        }
    }
}

#Preview {
    OrgApplications()
        .environment(SessionStore())
}
