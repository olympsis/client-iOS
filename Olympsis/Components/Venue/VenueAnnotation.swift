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
        // Imported/scraped venues may have no media, so guard the subscript
        // instead of indexing `[0]` directly (which would crash). `nil` here
        // falls through to the SF Symbol placeholder in `body`.
        guard let first = venue.images.first else { return nil }
        return generateImageURL(first)
    }
    
    var hasEvents: Bool {
        // Shares `Venue.hosts(_:)` with the venue detail list so the dot and the
        // list always agree on what counts as an event at this venue.
        return session.events.contains { venue.hosts($0) }
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
                // Fallback when a venue has no image (or the URL fails to
                // build): show a neutral SF Symbol on the prime-colored pin.
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
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
