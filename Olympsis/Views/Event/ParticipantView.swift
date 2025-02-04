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
        guard let data = participant.user,
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
            return Color("color-prime")
        case .Maybe:
            return Color("color-secnd")
        }
    }
    
    var body: some View {
        UserBadgeView(size: .medium, imageURL: imageURL)
            .overlay {
                Circle()
                    .stroke(ringColor, lineWidth: 2)
            }
    }
}

#Preview {
    ParticipantView(participant: EVENTS[0].participants![0])
}
