//
//  OrgManagerInvite.swift
//  Olympsis
//
//  Created by Joel on 12/24/23.
//

import os
import SwiftUI
import SwiftToast

struct OrgManagerInvite: View {
    
    @State private var text = ""
    @State private var users: [UserData] = [UserData]()
    @State private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "org_manager_invite_view")
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $text, onCommit: {
                    Task {
                        do {
                            users = try await session.userObserver.SearchUsersByUsername(username: text)
                        } catch {
                            log.error("Failed to search for users: \(error.localizedDescription)")
                        }
                    }
                }).padding(.horizontal)
                    .frame(height: 40)
                if users.count == 0 {
                    Spacer()
                    Text("Users Lookup")
                    Spacer()
                } else {
                    ScrollView {
                        ForEach(users, id: \.uuid) { user in
                            UserDataListView(data: user)
                        }
                    }
                }
            }.toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                }
            }
            .navigationTitle("Invite a Manager")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    OrgManagerInvite()
        .environmentObject(SessionStore())
}
