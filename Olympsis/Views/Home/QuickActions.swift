//
//  QuickActions.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/17/25.
//

import SwiftUI

struct QuickActions: View {
    
    private var showEvents: Bool {
        guard let user = session.user,
              let uuid = user.uuid else { return true }
        return session.events.mostRecentForUser(uuid: uuid) == nil
    }
    
    private var showGroups: Bool {
        guard let user = session.user,
              let clubs = user.clubs else { return true }
        return clubs.isEmpty
    }
    
    @Environment(\.openURL) private var openURL
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if (showEvents && session.state == .success) {
                Button(action: { openURL(URL(string: "olympsis://events")!)  }) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("LOOKUP EVENTS")
                                    .italic()
                                    .font(.title2)
                                    .fontWeight(.black)
                                Image(systemName: "calendar")
                                    .imageScale(.large)
                            }
                            
                            Text("Find where the game's happening. Get out & play!")
                                .font(.caption)
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: 65)
                .padding(.horizontal)
                .foregroundStyle(Color.white)
                .background {
                    Rectangle()
                        .foregroundStyle(Color.Brand.primary)
                        .cornerRadius(radius: 10, corners: showEvents && showGroups ? [.topLeft, .topRight] : [.allCorners])
                }
                .padding(.horizontal)
            }
            
            if (showGroups && session.state == .success) {
                Button(action: { openURL(URL(string: "olympsis://groups")!) }) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("SEARCH GROUPS")
                                    .italic()
                                    .font(.title2)
                                    .fontWeight(.black)
                                Image(systemName: "person.3.fill")
                                    .imageScale(.large)
                            }
                            
                            Text("Join local communities and meet new friends")
                                .font(.caption)
                        }
                        Spacer()
                    }
                }
                .frame(height: 65)
                .padding(.horizontal)
                .foregroundStyle(Color.foreground)
                .background {
                    Rectangle()
                        .foregroundStyle(Color.Background.secondary)
                        .cornerRadius(radius: 10, corners: showEvents && showGroups ? [.bottomLeft, .bottomRight] : [.allCorners])
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    QuickActions()
        .environment(SessionStore())
}
