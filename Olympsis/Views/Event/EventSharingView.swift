//
//  EventSharingView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/30/24.
//

import SwiftUI
import Kingfisher

struct EventSharingView: View {
    
    var event: Event
    
    var imageURL: URL? {
        guard let link = event.imageURL else {
            return nil
        }
        return generateImageURL(link)
    }
    
    var body: some View {
        VStack {
            if let url = imageURL {
                KFImage(url)
                    .resizable()
                    .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0), alignment: .center)
            }
            
            Spacer()
            
            HStack {
                
            }
        }
    }
}

#Preview {
    EventSharingView(event: EVENTS[0])
}


struct EventSharingTemplate {
    var titlePosition: String
    var timePosition: String
    var fieldNamePosition: String
}
