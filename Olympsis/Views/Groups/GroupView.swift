//
//  GroupView.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import os
import SwiftUI

struct GroupView: View {
    
    @EnvironmentObject private var session: SessionStore
    
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "group_view")
    
    var body: some View {
        NavigationStack {
            VStack {
                switch session.clubsState {
                case .loading:
                    ClubLoadingView()
                case .success, .pending:
                    VStack {
                        switch session.selectedGroup?.type {
                        case .Club:
                            if let club = session.selectedGroup?.club {
                                ClubView(club: club)
                                    .task {
                                        await session.updateNotifications()
                                    }
                            }
                        case .Organization:
                            if let org = session.selectedGroup?.organization {
                                OrganizationView(org: org)
                                    .task {
                                        await session.updateNotifications()
                                    }
                            }
                        case nil:
                            ClubsList()
                        }
                    }
                case .failure:
                    ClubsList()
                }
            }
            .task {
                if session.groups.isEmpty {
                    await session.CheckIn()
                }
            }
        }
    }
    
}

#Preview {
    GroupView()
        .environmentObject(SessionStore())
}
