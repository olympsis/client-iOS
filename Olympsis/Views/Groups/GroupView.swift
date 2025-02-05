//
//  GroupView.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import os
import SwiftUI

struct GroupView: View {
    
    @StateObject public var router: GroupRouter
    @Environment(SessionStore.self) private var session
    
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "group_view")
    
    init(router: GroupRouter = GroupRouter()) {
        self._router = StateObject(wrappedValue: router)
    }
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            Group {
                switch session.clubsState {
                case .loading:
                    ClubLoadingView()
                case .success, .pending:
                    Group {
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
        .environment(SessionStore())
}
