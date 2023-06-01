//
//  EventHostClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventDetailHostClubView: View {
    @State var club: Club
    var body: some View {
        VStack(alignment: .leading){
            Text("Host")
                .font(.title)
                .foregroundColor(.primary)
                .bold()
            
            Text(club.name!)
                .font(.title2)
                .foregroundColor(.primary)
                .bold()
            
            AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + (club.imageURL ?? ""))){ phase in
                if let image = phase.image {
                    image // Displays the loaded image.
                        .fixedSize()
                        .frame(width: SCREEN_WIDTH-20, height: 250)
                        .scaledToFit()
                        .clipped()
                        .cornerRadius(10)
                } else if phase.error != nil {
                    ZStack {
                        Color.gray // Indicates an error.
                            .clipShape(Circle())
                        .opacity(0.3)
                        Image(systemName: "exclamationmark.circle")
                    }
                } else {
                    ZStack {
                        Color.gray // Acts as a placeholder.
                            .opacity(0.3)
                        .cornerRadius(10)
                        ProgressView()
                    }
                }
            }.frame(height: 250)
            
            Text(club.description ?? "")
                .padding(.top, 5)
                .padding(.bottom)
        }.frame(width: SCREEN_WIDTH-20)
    }
}

struct EventDetailHostClubView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailHostClubView(club: CLUBS[0])
    }
}
