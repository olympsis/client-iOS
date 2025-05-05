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
    
    private var selectedGroup: GroupSelection? {
        guard let group = session.selectedGroup else {
            return nil
        }
        
        return group
    }
    
    private var selecteGroupType: GROUP_TYPE {
        guard selectedGroup != nil else {
            return .Club
        }
        
        return selectedGroup!.type
    }
    
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
                    if selectedGroup != nil {
                        switch selecteGroupType {
                        case .Club:
                            if let club = selectedGroup?.club {
                                ClubView(club: club)
                                    .id(club.id)
                                    .task {
                                        await session.updateNotifications()
                                    }
                            }
                        case .Organization:
                            if let org = selectedGroup?.organization {
                                OrganizationView(org: org)
                                    .id(org.id)
                                    .task {
                                        await session.updateNotifications()
                                    }
                            }
                        }
                    } else {
                        ClubsList()
                    }
                case .failure:
                    ClubsList()
                }
            }.task {
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
