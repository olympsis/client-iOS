//
//  ClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI

struct ClubView: View {
    @State var club: Club
    var body: some View {
        VStack(alignment: .leading){
            AsyncImage(url: URL(string: club.imageURL)){ phase in
                if let image = phase.image {
                        image // Displays the loaded image.
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(5)
                            .frame(width: SCREEN_WIDTH, height: 250, alignment: .center)
                            .clipped()
                    } else if phase.error != nil {
                        Color.red // Indicates an error.
                    } else {
                        Color.gray // Acts as a placeholder.
                    }
            }.frame(width: SCREEN_WIDTH, height: 250, alignment: .center)
            Text("\(club.name)")
                .font(.largeTitle)
                .bold()
                .padding(.leading)
            Text(club.description)
                .padding(.leading)
            if club.members.count > 1 {
                Text("\(club.members.count) members")
                    .opacity(0.5)
                    .foregroundColor(.primary)
                    .padding(.leading)
            } else {
                Text("\(club.members.count) member")
                    .opacity(0.7)
                    .foregroundColor(.primary)
                    .padding(.leading)
            }
            
        }
    }
}

struct ClubView_Previews: PreviewProvider {
    static var previews: some View {
        ClubView(club: Club(owner: "", name: "Provo Soccer", description: "Come play soccer with us.", isPrivate: false, location: GeoJSON(type: "Point", coordinates: ["40.249480", "-111.655317"]), city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/fields/1309-22-3679.jpg", members: [Member](), rules: ["Don't steal", "No Fighting"], createdAt: ""))
    }
}
