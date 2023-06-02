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
                    } else if phase.error != nil {
                        ZStack {
                            Color.gray // Indicates an error.
                                .frame(width: SCREEN_WIDTH, height: 500)
                            Image(systemName: "exclamationmark.circle")
                        }
                    } else {
                        ZStack {
                            Color.gray // Acts as a placeholder.
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
