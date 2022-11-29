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
            AsyncImage(url: announcement.imageURL){ image in
                image.resizable()
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.3)
                    .frame(width: SCREEN_WIDTH, height: 500)
            }.frame(width: SCREEN_WIDTH, height: 500)
        }
    }
}

struct AnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementView(announcement: Announcement(id: "0", image: "https://olympsis.s3.us-west-2.amazonaws.com/annoucements/Welcome+Image+-+Soccer.jpg"))
    }
}
