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
    
    var groupViewModel: GroupViewModel {
        return session.groupViewModel
    }
    
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
                            }
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
                    }
                }
            }
            .fullScreenCover(isPresented: $showMenu) {
                if let group = session.selectedGroup {
                    if let club = group.club {
                        ClubMenu(club: club)
                    }
                }
            }
            .fullScreenCover(isPresented: $showNewPost) {
                if let group = session.selectedGroup {
                    if let club = group.club {
                        CreateNewPost(club: club)
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
