//
//  ParticipantView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/18/22.
//

import SwiftUI

struct ParticipantView: View {
    @State var participant: Participant
    
    var imageURL: String {
        guard let data = participant.data,
              let img = data.imageURL else {
            return ""
        }
        return GenerateImageURL(img)
    }
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)){ phase in
            if let image = phase.image {
                ZStack {
                    Circle()
                        .foregroundColor(Color("primary-color"))
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
                        .foregroundColor(Color("primary-color"))
                    Color.gray // Indicates an error.
                        .clipShape(Circle())
                        .frame(width: 55, height: 55)
                    Image(systemName: "exclamationmark.circle")
                }.frame(width: 65, height: 65)
            } else {
                ZStack {
                    Circle()
                        .frame(width: 65, height: 65)
                        .foregroundColor(Color("primary-color"))
                    Color.gray // Acts as a placeholder.
                        .clipShape(Circle())
                        .frame(width: 55, height: 55)
                    ProgressView()
                }.frame(width: 65, height: 65)
            }
        }
    }
}

struct ParticipantView_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantView(participant: EVENTS[0].participants![0])
    }
}
