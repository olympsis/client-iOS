//
//  EventAnnotation.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/4/26.
//
//  Map pin for a single event — mirrors `VenueAnnotation`'s circular
//  KFImage badge so events and venues read consistently on the map but
//  stay visually distinct via the accent ring color (events use the
//  brand color, venues use the prime color).
//

import SwiftUI
import Kingfisher

struct EventAnnotation: View {

    var event: Event

    private var imageURL: URL? {
        generateImageURL(event.mediaURL)
    }

    var body: some View {
        ZStack {
            Circle()
                .frame(width: 48, height: 48)
                .foregroundStyle(Color.Brand.primary)
            if let link = imageURL {
                KFImage(link)
                    .placeholder {
                        Circle()
                            .foregroundStyle(.gray)
                            .overlay { ProgressView() }
                    }
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
    }
}

/// Pin shown when multiple events collapse into a single cluster at the
/// current zoom level. Just a "+N" badge — minimal so clusters don't
/// dominate the map at low zoom levels.
struct EventClusterAnnotation: View {

    var events: [Event]

    var body: some View {
        Text("+\(events.count)")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Circle().fill(Color.Brand.quaternary))
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }
}

#Preview("Single") {
    EventAnnotation(event: EVENTS[0])
}

#Preview("Cluster") {
    EventClusterAnnotation(events: EVENTS)
}
