//
//  AnnouncementView.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import SwiftUI
import Kingfisher

struct AnnouncementView: View {
    
    @State var announcement: Announcement
    var url: URL? {
        return generateImageURL(announcement.imageURL)
    }
    
    var body: some View {
        VStack {
            if let link = url {
                KFImage(link)
                    .placeholder({
                        ImageLoadingView()
                    })
                    .resizable()
                    .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0))
                    .scaledToFit()
                    .clipped()
            } else {
                ImageLoadingFailedView()
                    .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0))
            }
        }
    }
}

struct AnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementView(announcement: ANNOUCEMENTS[0])
    }
}
