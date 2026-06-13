//
//  ParticipantView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/18/22.
//

import SwiftUI

/// A view that shows a picture of a participant
struct ParticipantView: View {
    
    var participant: Participant
    var posterOrAdminViewing: Bool = false
    
    private var isUserAnonymous: Bool {
        // Posters or admins get full viewing rights
        if posterOrAdminViewing { return false }
        
        return participant.isAnonymous
    }
    
    private var imageURL: URL? {
        guard !isUserAnonymous,
            let data = participant.user,
              let img = data.imageURL else {
            return nil
        }
        return generateImageURL(img)
    }
    
    /// The color used for the trailing RSVP status text. Matches the brand
    /// color that previously tinted the avatar ring so each response type
    /// stays visually distinguishable.
    private var statusColor: Color {
        switch participant.status {
        case .Yes:
            return Color.Brand.primary
        case .Maybe:
            return Color.Brand.secondary
        case .Waitlist:
            return Color.Brand.tertiary
        }
    }
    
    /// The localized, all-caps RSVP status text shown on the trailing edge
    /// (e.g. YES, MAYBE, WAITLISTED).
    private var statusText: String {
        switch participant.status {
        case .Yes:
            return String(localized: "participant-status-yes", defaultValue: "YES", table: "Events")
        case .Maybe:
            return String(localized: "participant-status-maybe", defaultValue: "MAYBE", table: "Events")
        case .Waitlist:
            return String(localized: "participant-status-waitlisted", defaultValue: "WAITLISTED", table: "Events")
        }
    }
    
    private var name: String {
        guard let first = participant.user?.firstName,
              let last = participant.user?.lastName else {
            return "Olympsis User"
        }
        
        return isUserAnonymous ? "Anonymous User" : "\(first) \(last)"
    }
    
    private var username: String {
        guard let username = participant.user?.username else {
            return "olympsis-user"
        }
        
        return isUserAnonymous ? "@anon-user" : "@\(username)"
    }
    
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        HStack {
            UserBadgeView(size: .small, imageURL: imageURL)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(name)
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    if isUserAnonymous && (session.user?.userID == participant.user?.userID) {
                        Text(String(localized: "event-participant-you", table: "Events"))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.Brand.tertiary)
                    }
                }
                
                Text(username)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            // RSVP response status, shown bold/italic/all-caps on the trailing edge.
            Text(statusText)
                .font(.caption)
                .fontWeight(.bold)
                .italic()
                .foregroundStyle(statusColor)
        }
    }
}

#Preview {
    ParticipantView(participant: EVENTS[0].participants[0])
        .environment(SessionStore())
}
