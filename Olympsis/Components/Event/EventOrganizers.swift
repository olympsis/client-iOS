//
//  EventOrganizersView.swift
//  Olympsis
//
//  Created by Joel on 12/11/23.
//

import SwiftUI

struct EventOrganizers: View {
    
    @State var event: Event
    @Binding var clubs: [Club]
    @Binding var organizations: [Organization]
    
    @State private var showFirst: Bool = false
    @State private var showSecond: Bool = false
    @State private var showGroups: Bool = false
    @State private var state: LOADING_STATE = .pending
    
    // Organizers info
    private var organizers: [Organizer] {
        return event.organizers
    }
    
    // Poster information
    private var imageURL: URL? {
        guard let data = event.poster,
              let img = data.imageURL else {
            return nil
        }
        return generateImageURL(img)
    }
    
    private var canShowPoster: Bool {
        guard let config = event.config,
              let hidePoster = config.hidePoster else {
            return true
        }
        
        return !hidePoster
    }
    
    private var posterName: String {
        guard let data = event.poster,
              let firstName = data.firstName,
              let lastName = data.lastName else {
            return "Olympsis User"
        }
        return "\(firstName) \(lastName)"
    }
    
    private var posterUsername: String {
        guard let data = event.poster,
              let username = data.username else {
            return "olympsis-user"
        }
        return "@\(username)"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "hosted-title", table: "Events"))
                .font(.title2)
                .bold()
            
            // MARK: - Poster
            if canShowPoster {
                HStack {
                    UserBadgeView(size: .small, imageURL: imageURL)
                    
                    VStack(alignment: .leading) {
                        Text(posterName)
                            .font(.callout)
                            .fontWeight(.bold)
                        Text(posterUsername)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            // MARK: - Groups
            VStack(alignment: .leading) {
                ForEach(organizers, id: \.id) { organizer in
                    HStack {
                        switch organizer.type {
                        case .Club:
                            if let club = clubs.first(where: { $0.id == organizer.id }) {
                                if let url = club.logo {
                                    GroupBadgeView(size: .small, type: organizer.type, imageURL: generateImageURL(url))
                                    Text(club.name)
                                        .fontWeight(.bold)
                                } else {
                                    GroupBadgeView(size: .small, type: organizer.type)
                                    Text(club.name)
                                        .fontWeight(.bold)
                                }
                            }
                        case .Organization:
                            if let org = organizations.first(where: { $0.id == organizer.id }) {
                                if let url = org.logo {
                                    GroupBadgeView(size: .small, type: organizer.type, imageURL: generateImageURL(url))
                                    Text(org.name)
                                        .fontWeight(.bold)
                                } else {
                                    GroupBadgeView(size: .small, type: organizer.type)
                                    Text(org.name)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    EventOrganizers(event: EVENTS[0], clubs: .constant(CLUBS), organizations: .constant(ORGANIZATIONS))
        .environment(SessionStore())
}
