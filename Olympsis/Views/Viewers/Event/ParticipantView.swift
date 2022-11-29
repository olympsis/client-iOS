//
//  ParticipantView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/18/22.
//

import SwiftUI

struct ParticipantView: View {
    @State var participant: Participant
    var body: some View {
        AsyncImage(url: URL(string: participant.imageURL)){ image in
            ZStack {
                Circle()
                    .frame(width: 55, height: 55)
                    .foregroundColor(Color("primary-color"))
                image
                    .resizable()
                    .clipShape(Circle())
                    .scaledToFit()
                .frame(width: 70, height: 70)
            }
                
        } placeholder: {
            Circle()
                .frame(width: 70, height: 70)
        }
    }
}

struct ParticipantView_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantView(participant: Participant(id: "", uuid: "", status: "going", imageURL: "https://storage.googleapis.com/olympsis-1/profile-img/dorrell-tibbs-GntSiIMHyVM-unsplash.jpg", createdAt: 0))
    }
}
