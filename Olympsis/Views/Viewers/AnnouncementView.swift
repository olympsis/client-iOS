//
//  AnnouncementView.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import SwiftUI

struct AnnouncementView: View {
    @State var announcement: Announcement
    
    var body: some View {
        VStack {
            AsyncImage(url: announcement.imageURL){ phase in
                if let image = phase.image {
                        image // Displays the loaded image.
                            .resizable()
                            .frame(width: SCREEN_WIDTH, height: 500)
                            .scaledToFit()
                            .clipped()
                            .cornerRadius(10)
                    } else if phase.error != nil {
                        ZStack {
                            Color.gray // Indicates an error.
                                .cornerRadius(10)
                                .frame(width: SCREEN_WIDTH, height: 500)
                            Image(systemName: "exclamationmark.circle")
                        }
                    } else {
                        ZStack {
                            Color.gray // Acts as a placeholder.
                                .cornerRadius(10)
                                .frame(width: SCREEN_WIDTH, height: 500)
                            ProgressView()
                        }
                    }
            }
        }
    }
}

struct AnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementView(announcement: Announcement(id: "0", image: "https://olympsis.s3.us-west-2.amazonaws.com/annoucements/Welcome+Image+-+Soccer.jpg"))
    }
}
