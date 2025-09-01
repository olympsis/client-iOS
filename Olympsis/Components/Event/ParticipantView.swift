//
//  ParticipantView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/18/22.
//

import SwiftUI

/// A view that shows a picture of a participant
struct ParticipantView: View {
    
    @State var participant: Participant
    
    private var imageURL: URL? {
        guard !participant.isAnonymous,
            let data = participant.user,
              let img = data.imageURL else {
            return nil
        }
        return generateImageURL(img)
    }
    
    private var ringColor: Color {
        guard participant.user != nil else {
            return Color("color-prime")
        }
        
        switch participant.status {
        case .Yes:
            return Color.Brand.primary
        case .Maybe:
            return Color.Brand.secondary
        case .Waitlist:
            return Color.Brand.tertiary
        }
    }
    
    private var name: String {
        guard let first = participant.user?.firstName,
              let last = participant.user?.lastName else {
            return "Olympsis User"
        }
        
        return participant.isAnonymous ? "Anonymous User" : "\(first) \(last)"
    }
    
    private var username: String {
        guard let username = participant.user?.username else {
            return "olympsis-user"
        }
        
        return participant.isAnonymous ? "@anon-user" : "@\(username)"
    }
    
    private var isUserAnonymous: Bool {
        guard participant.isAnonymous,
              let uuid = session.user?.uuid,
              participant.user?.uuid == uuid else {
            return false
        }
        return true
    }
    
    @Environment(SessionStore.self) private var session: SessionStore
    
    var body: some View {
        HStack {
            UserBadgeView(size: .small, imageURL: imageURL)
                .overlay {
                    Circle()
                        .stroke(ringColor, lineWidth: 2)
                }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(name)
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    if isUserAnonymous {
                        Text("(You)")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.Brand.tertiary)
                    }
                }
                
                Text(username)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    ParticipantView(participant: EVENTS[0].participants[0])
        .environment(SessionStore())
}
