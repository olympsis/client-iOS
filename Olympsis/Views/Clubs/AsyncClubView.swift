//
//  AsyncClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/8/25.
//

import os
import SwiftUI

struct AsyncClubView: View {
    
    @State public var clubID: String
    @State private var club: Club?
    @State private var title: String = "Club"
    @State private var state: VIEW_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "async_club_view")
    
    @MainActor
    private func fetchClub() async {
        state = .loading
        guard let club = await session.clubObserver.getClub(id: clubID) else {
            state = .failure
            log.error("Failed to fetch club:\(clubID, privacy: .public)")
            return
        }
        self.title = club.name
        self.club = club
        state = .success
    }
    
    var body: some View {
        Group {
            switch state {
            case .pending, .loading:
                ProgressView()
                    .padding(.vertical, 100)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { Task {
                                await fetchClub()
                            } }) {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    .navigationTitle(title)
                    .navigationBarBackButtonHidden()
                    .navigationBarTitleDisplayMode(.inline)
            case .success:
                if let club {
                    ClubDetailView(club: club)
                }
            case .failure:
                VStack {
                    Image("illustrations/sorry")
                        .resizable()
                        .frame(width: 250, height: 250)
                    Text("Failed to get Club")
                        .fontWeight(.bold)
                    Button(action: { Task { await fetchClub() }}) {
                        Text("Try again")
                    }
                }
                .padding(.vertical, 100)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { Task {
                            await fetchClub()
                        } }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                .navigationTitle(title)
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(club != nil ? .hidden : .visible, for: .tabBar)
            }
        }
        .task {
            await fetchClub()
        }
    }
}

#Preview {
    AsyncClubView(clubID: "")
        .environment(SessionStore())
}
