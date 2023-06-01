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
    
    @StateObject var clubObserver = ClubObserver()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    if applications.filter({$0.status != "accepted"}).count > 0 {
                        ForEach(applications.filter({$0.status != "accepted"})) { application in
                            ClubApplicationView(club: club, application: application, applications: $applications)
                        }
                    } else {
                        Text("No Applications")
                    }
                    
                }.refreshable {
                    let res = await clubObserver.getApplications(id: club.id!)
                    await MainActor.run {
                        applications = res
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("primary-color"))
                    }
                }
            }
            .navigationTitle("Applications")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                let res = await clubObserver.getApplications(id: club.id!)
                await MainActor.run {
                    applications = res
                }
            }
        }
    }
}

struct ClubApplications_Previews: PreviewProvider {
    static var previews: some View {
        ClubApplications(club: CLUBS[0])
    }
}
