//
//  VenueMapButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/22/24.
//

import SwiftUI
import Kingfisher

struct VenueAnnotation: View {
    
    var venue: Venue
    @EnvironmentObject var session: SessionStore
    
    var imageURL: URL? {
        return generateImageURL(venue.images[0])
    }
    
    var hasEvents: Bool {
        let events = session.events.filter { 
            $0.venues?.contains(where: { desc in
                if desc.id == venue.id {
                    return true
                } else if desc.name == venue.name {
                    return true
                }
                return false
            }) ?? false
        }
        
        return events.count > 0
    }
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 48, height: 48)
                .foregroundStyle(.colorPrime)
            if let link = imageURL {
                KFImage(link)
                    .resizable()
                    .cacheOriginalImage()
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 100, height: 100)))
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.gray)
            }
        }
        .overlay(alignment: .topTrailing) {
            if hasEvents {
                Circle()
                    .foregroundStyle(.red)
                    .frame(width: 15, height: 15)
            }
        }
    }
}

#Preview {
    VenueAnnotation(venue: FIELDS[0])
        .environmentObject(SessionStore())
}
