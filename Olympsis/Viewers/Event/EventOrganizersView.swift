//
//  EventOrganizersView.swift
//  Olympsis
//
//  Created by Joel on 12/11/23.
//

import SwiftUI

struct EventOrganizersView: View {
    
    @State var event: Event
    @State private var showFirst: Bool = false
    @State private var showSecond: Bool = false
    @State private var showGroups: Bool = false
    
    /// The list of the associated groups that are organizing this event
    private var organizers: [Organizer] {
        guard let organizers = event.organizers else {
            return [Organizer]()
        }
        return organizers
    }
    
    /// The first group that is organizing this event
    private var host: String {
        guard let data = event.data else {
            return "organizer"
        }
        guard let o = organizers.first else {
            return "organizer"
        }
        if o.type == GROUP_TYPE.Club.rawValue {
            guard let club = data.clubs?.first(where: { $0.id == o.id }),
                  let name = club.name else {
                return "organizer"
            }
            return name
        } else {
            guard let org = data.organizations?.first(where: { $0.id == o.id }),
                  let name = org.name else {
                return "organizer"
            }
            return name
        }
    }
    
    /// the co host or second organizer if there is only two
    private var coHost: String {
        guard let data = event.data else {
            return "organizer"
        }
        if organizers.count == 2 {
            if organizers[1].type == GROUP_TYPE.Club.rawValue {
                guard let club = data.clubs?.first(where: { $0.id == organizers[1].id }),
                      let name = club.name else {
                    return "organizer"
                }
                return name
            } else {
                guard let org = data.organizations?.first(where: { $0.id == organizers[1].id }),
                      let name = org.name else {
                    return "organizer"
                }
                return name
            }
        }
        return "organizer"
    }
    
    var body: some View {
        HStack(spacing: 5) {
            if organizers.count == 1 {
                Text(host)
                    .font(.callout)
                    .bold()
                    .onTapGesture {
                        self.showFirst.toggle()
                    }
                    .fullScreenCover(isPresented: $showFirst, content: {
                        if let org = organizers.first {
                            if org.type == GROUP_TYPE.Club.rawValue {
                                if let data = event.data,
                                   let clubs = data.clubs,
                                   let club = clubs.first(where: { $0.id == org.id }) {
                                    ClubView(club: club)
                                }
                            } else {
                                if let data = event.data,
                                   let orgs = data.organizations,
                                   let org = orgs.first(where: { $0.id == org.id }) {
                                    OrgView(organization: org)
                                }
                            }
                            
                        }
                    })
            } else if organizers.count == 2 {
                Text(host)
                    .font(.callout)
                    .bold()
                    .onTapGesture {
                        self.showFirst.toggle()
                    }
                    .fullScreenCover(isPresented: $showFirst, content: {
                        if let org = organizers.first {
                            if org.type == GROUP_TYPE.Club.rawValue {
                                if let data = event.data,
                                   let clubs = data.clubs,
                                   let club = clubs.first(where: { $0.id == org.id }) {
                                    ClubView(club: club)
                                }
                            } else {
                                if let data = event.data,
                                   let orgs = data.organizations,
                                   let org = orgs.first(where: { $0.id == org.id }) {
                                    OrgView(organization: org)
                                }
                            }
                            
                        }
                    })
                Text("and")
                    .font(.callout)
                Text(coHost)
                    .font(.callout)
                    .bold()
                    .onTapGesture {
                        self.showSecond.toggle()
                    }
                    .fullScreenCover(isPresented: $showSecond, content: {
                        if organizers[1].type == GROUP_TYPE.Club.rawValue {
                            if let data = event.data,
                               let clubs = data.clubs,
                               let club = clubs.first(where: { $0.id == organizers[1].id }) {
                                ClubView(club: club)
                            }
                        } else {
                            if let data = event.data,
                               let orgs = data.organizations,
                               let org = orgs.first(where: { $0.id == organizers[1].id }) {
                                OrgView(organization: org)
                            }
                        }
                    })
            } else {
                Text(host)
                    .font(.callout)
                    .bold()
                    .onTapGesture {
                        self.showFirst.toggle()
                    }
                    .fullScreenCover(isPresented: $showFirst, content: {
                        if let org = organizers.first {
                            if org.type == GROUP_TYPE.Club.rawValue {
                                if let data = event.data,
                                   let clubs = data.clubs,
                                   let club = clubs.first(where: { $0.id == org.id }) {
                                    ClubView(club: club)
                                }
                            } else {
                                if let data = event.data,
                                   let orgs = data.organizations,
                                   let org = orgs.first(where: { $0.id == org.id }) {
                                    OrgView(organization: org)
                                }
                            }
                            
                        }
                    })
                Text("and")
                Text("\(organizers.count-1) others")
                    .font(.callout)
                    .bold()
                    .onTapGesture {
                        self.showGroups.toggle()
                    }
                    .sheet(isPresented: $showGroups, content: {
                        if organizers.first != nil {
                            GroupsView(organizers: organizers, clubs: event.data?.clubs ?? [Club](), organizations: event.data?.organizations ?? [Organization]())
                                .presentationDetents([.medium, .large])
                        }
                    })
            }
        }
    }
}

#Preview {
    EventOrganizersView(event: EVENTS[2])
}
