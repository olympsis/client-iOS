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
    
    var imageURL: String {
        guard let data = participant.data,
              let img = data.imageURL else {
            return "https://api.olympsis.com"
        }
        return GenerateImageURL(img)
    }
    
    var ringColor: Color {
        guard participant.data != nil else {
            return Color("color-prime")
        }
        if participant.status == "yes" {
            return Color("color-prime")
        } else if participant.status == "maybe" {
            return Color("color-secnd")
        } else {
            return Color("color-tert")
        }
    }
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)){ phase in
            if let image = phase.image {
                ZStack {
                    Circle()
                        .foregroundColor(ringColor)
                    image // Displays the loaded image.
                        .resizable()
                        .clipShape(Circle())
                        .scaledToFill()
                        .clipped()
                        .frame(width: 55, height: 55)
                }.frame(width: 65, height: 65)
            } else if phase.error != nil {
                ZStack {
                    Circle()
                        .frame(width: 65, height: 65)
                        .foregroundColor(ringColor)
                    Color.gray // Indicates an error.
                        .clipShape(Circle())
                        .frame(width: 55, height: 55)
                    Image(systemName: "person")
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                }.frame(width: 65, height: 65)
            } else {
                ZStack {
                    Circle()
                        .frame(width: 65, height: 65)
                        .foregroundColor(ringColor)
                    Color.gray // Acts as a placeholder.
                        .clipShape(Circle())
                        .frame(width: 55, height: 55)
                    ProgressView()
                }.frame(width: 65, height: 65)
            }
        }
    }
}

#Preview {
    ParticipantView(participant: EVENTS[0].participants![0])
}
