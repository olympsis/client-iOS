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
    
    var imageURL: URL? {
        guard let data = participant.user,
              let img = data.imageURL else {
            return nil
        }
        return generateImageURL(img)
    }
    
    var body: some View {
        UserBadgeView(size: .medium, imageURL: imageURL)
    }
}

#Preview {
    ParticipantView(participant: EVENTS[0].participants![0])
}
