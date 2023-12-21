//
//  GroupView.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import SwiftUI

struct GroupView: View {
    
    @State private var showMenu: Bool = false
    @State private var showNewPost: Bool = false
    @State private var showSelector: Bool = false
    @State private var showMessages: Bool = false
    @State private var showNewGroup: Bool = false
    @State private var groupState: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    
    func retryFetchingClubData() {
        groupState = .loading
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch session.clubsState {
                case .loading:
                    ProgressView()
                case .success, .pending:
                    VStack {
                        if let group = session.selectedGroup {
                            if let club = group.club {
                                ClubFeed(club: club)
                            } else if let org = group.organization {
                                OrgFeed(organization: org)
                            }
                        } else {
                            ClubsList()
                        }
                    }
                case .failure:
                    VStack {
                        Text("Failed to get clubs data 😞")
                    }
                }
            }.toolbar {
                GroupToolbar(showMenu: $showMenu, showNewPost: $showNewPost, showSelector: $showSelector, showMessages: $showMessages ,groupState: $groupState)
            }
            .sheet(isPresented: $showSelector) {
                GroupSelector(showNewGroup: $showNewGroup, groups: session.groups)
                    .presentationDetents([.medium])
            }
            .fullScreenCover(isPresented: $showMessages) {
                if let group = session.selectedGroup {
                    if let club = group.club {
                        Messages(club: club)
                    } else if let org = group.organization {
                        GroupMessages(org: org)
                    }
                }
            }
            .fullScreenCover(isPresented: $showMenu) {
                if let group = session.selectedGroup {
                    if let club = group.club {
                        ClubMenu(club: club)
                    } else if let org = group.organization {
                        OrgMenu(organization: org)
                    }
                } else {
                    NoClubMenu(status: $groupState)
                }
            }
            .fullScreenCover(isPresented: $showNewPost) {
                if let group = session.selectedGroup {
                    if let club = group.club {
                        CreateNewPost(club: club)
                    } else if let org = group.organization {
                        CreateNewAnnouncement(organization: org)
                    }
                }
            }
            .fullScreenCover(isPresented: $showNewGroup) {
                NewGroup()
            }
        }
    }
    
}

#Preview {
    GroupView()
        .environmentObject(SessionStore())
}
