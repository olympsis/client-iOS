//
//  GroupView.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import os
import SwiftUI

struct GroupView: View {
    
    @Binding public var router: GroupRouter
    @State private var manager = SearchManager()
    @Environment(SessionStore.self) private var session
    
    private var selectedGroup: GroupSelection? {
        guard let group = session.groupsManager.selected else {
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
    
    private let log: Logger = Logger(
        subsystem: "com.olympsis.client",
        category: "group_view"
    )
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            Group {
                switch session.clubsState {
                case .loading:
                    ClubLoadingView()
                case .success, .pending:
                    if let selectedGroup {
                        switch selecteGroupType {
                        case .Club:
                            if let club = selectedGroup.club {
                                ClubView(club: club)
                                    .id(club.id)
                            }
                        case .Organization:
                            if let org = selectedGroup.organization {
                                OrganizationView(org: org)
                                    .id(org.id)
                            }
                        }
                    } else {
                        ClubsList()
                    }
                case .failure:
                    FatalErrorView()
                }
            }
            .navigationDestination(for: GROUP_ROUTES.self, destination: { route in
                switch route {
                case .clubsList(let id):
                    if let id {
                        AsyncClubView(clubID: id)
                    } else {
                        ClubsList()
                    }
                default:
                    FatalErrorView()
                }
            })
            .task {
                await session.updateNotifications()
            }
        }
    }
}

#Preview {
    GroupView(router: .constant(GroupRouter()))
        .environment(SessionStore())
}
