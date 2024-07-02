//
//  GroupView.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import os
import SwiftUI

struct GroupView: View {
    
    @State private var showMenu: Bool = false
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
                        if let selectedGroup = session.selectedGroup {
                            switch selectedGroup.type {
                            case .Club:
                                if let club = selectedGroup.club {
                                    ClubView(club: club)
                                        .task {
                                            await session.updateNotifications()
                                        }
                                }
                            case .Organization:
                                if let org = selectedGroup.organization {
                                    OrganizationView(org: org)
                                        .task {
                                            await session.updateNotifications()
                                        }
                                }
                            }
                        } else {
                            ClubsList()
                        }
                    }
                case .failure:
                    VStack(alignment: .center) {
                        Text("😞")
                        Text("Failed to get clubs data")
                    }
                }
            }
        }
    }
    
}

#Preview {
    GroupView()
        .environmentObject(SessionStore())
}
