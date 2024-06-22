//
//  GroupView.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import os
import SwiftUI

struct GroupView: View {
    
    @State private var showEULA: Bool = false
    @State private var showMenu: Bool = false
    @State private var showNewPost: Bool = false
    @State private var showNewEvent: Bool = false
    @State private var showSelector: Bool = false
    @State private var showMessages: Bool = false
    @State private var showNewGroup: Bool = false
    @State private var groupState: LOADING_STATE = .pending
    
    @EnvironmentObject private var session: SessionStore
    
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "group_view")
    
    private func retryFetchingClubData() {
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
                        if session.selectedGroup != nil {
                            GroupFeed(showNewPost: $showNewPost, showNewEvent: $showNewEvent)
                                .task {
                                    await session.updateNotifications()
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
            }
            .toolbar {
                GroupToolbar(showEULA: $showEULA, showMenu: $showMenu, showNewPost: $showNewPost, showNewEvent: $showNewEvent, showSelector: $showSelector, showMessages: $showMessages ,groupState: $groupState)
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
            .fullScreenCover(isPresented: $showNewGroup) {
                NewGroup()
            }
            .sheet(isPresented: $showEULA, content: {
                EndUserLicenseAgreement()
            })
        }
    }
    
}

#Preview {
    GroupView()
        .environmentObject(SessionStore())
}
