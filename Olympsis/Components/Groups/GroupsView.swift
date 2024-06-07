//
//  GroupsView.swift
//  Olympsis
//
//  Created by Joel on 12/12/23.
//

import SwiftUI

struct GroupsView: View {
    
    @State var organizers: [Organizer]
    @State var clubs: [Club]
    @State var organizations: [Organization]
    @State private var showOrg: Bool = false
    @State private var showClub: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ScrollView {
                    ForEach(organizers) { organizer in
                        if organizer.type == GROUP_TYPE.Club.rawValue {
                            HStack {
                                Circle()
                                    .frame(width: 60)
                                VStack {
                                    if let club = clubs.first(where: { $0.id == organizer.id }),
                                       let name = club.name {
                                        Text(name)
                                            .fullScreenCover(isPresented: $showClub, content: {
                                                ClubView(club: club)
                                            })
                                    }
                                }
                                Spacer()
                            }.padding(.horizontal)
                                .onTapGesture {
                                    self.showClub.toggle()
                                }
                        } else {
                            HStack {
                                Circle()
                                    .frame(width: 60)
                                VStack {
                                    if let org = organizations.first(where: { $0.id == organizer.id }),
                                       let name = org.name {
                                        Text(name)
                                            .fullScreenCover(isPresented: $showOrg, content: {
                                                OrgView(organization: org)
                                            })
                                    }
                                }
                                Spacer()
                            }.padding(.horizontal)
                                .onTapGesture {
                                    self.showOrg.toggle()
                                }
                        }
                    }
                }
            }.navigationTitle("Organizers")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GroupsView(organizers: EVENTS[0].organizers ?? [Organizer](), clubs: CLUBS, organizations: ORGANIZATIONS)
}
