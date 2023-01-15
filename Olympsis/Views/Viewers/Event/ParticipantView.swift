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
        if let img = participant.data.imageURL {
            AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + img)){ phase in
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
                    }
                } else {
                    ZStack {
                        Circle()
                            .frame(width: 65, height: 65)
                            .foregroundColor(Color("primary-color"))
                        Color.gray // Acts as a placeholder.
                            .clipShape(Circle())
                            .frame(width: 55, height: 55)
                        ProgressView()
                    }
                }
            }
        } else {
            ZStack {
                Circle()
                    .frame(width: 65, height: 65)
                    .foregroundColor(Color("primary-color"))
                Color.gray // Acts as a placeholder.
                    .clipShape(Circle())
                    .frame(width: 55, height: 55)
                ProgressView()
            }
        }
    }
}

struct ParticipantView_Previews: PreviewProvider {
    static var previews: some View {
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "profile-images/62D674D2-59D2-4095-952B-4CE6F55F681F", bio: "", sports: ["soccer"])
        ParticipantView(participant: Participant(id: "", uuid: "", status: "going", data: peek, createdAt: 0))
    }
}
