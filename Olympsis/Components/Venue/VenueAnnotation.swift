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
    @Environment(SessionStore.self) private var session
    
    var imageURL: URL? {
        return generateImageURL(venue.images[0])
    }
    
    var hasEvents: Bool {
        let events = session.events.filter { 
            $0.venues.contains(where: { desc in
                if desc.id == venue.id {
                    return true
                } else if desc.name == venue.name {
                    return true
                }
                return false
            })
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
                    .placeholder({
                        Circle()
                            .foregroundStyle(.colorPrime)
                            .overlay {
                                ProgressView()
                            }
                    })
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

/// Pin shown when multiple venues collapse into a single cluster at the
/// current zoom level. Mirrors `EventClusterAnnotation` so events and
/// venues feel consistent at low zoom levels.
struct VenueClusterAnnotation: View {

    var venues: [Venue]

    var body: some View {
        Text("+\(venues.count)")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Circle().fill(.colorPrime))
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }
}

#Preview {
    VenueAnnotation(venue: VENUES[0])
        .environment(SessionStore())
}

#Preview("Cluster") {
    VenueClusterAnnotation(venues: VENUES)
}
