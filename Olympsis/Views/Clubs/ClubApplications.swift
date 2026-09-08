//
//  ClubApplications.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct ClubApplications: View {
    
    @State var club: Club
    @State var applications = [ClubApplication]()
    
    private let clubService = ClubService()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    if applications.filter({$0.status != "accepted"}).count > 0 {
                        ForEach(applications.filter({$0.status != "accepted"})) { application in
                            ClubApplicationListItem(club: club, application: application, applications: $applications)
                                .padding(.horizontal, 10)
                        }
                    } else {
                        HStack {
                            Spacer()
                        }
                        Text("No applications found")
                    }
                    
                }.refreshable {
                    let res = await clubService.getApplications(id: club.id)
                    await MainActor.run {
                        applications = res
                    }
                }
            }
            .navigationTitle("Applications")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                let res = await clubService.getApplications(id: club.id)
                await MainActor.run {
                    applications = res
                }
            }
        }
    }
}

#Preview {
    ClubApplications(club: CLUBS[0])
}
