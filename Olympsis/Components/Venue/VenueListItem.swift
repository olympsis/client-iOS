//
//  VenueListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI
import Kingfisher
import CoreLocation

struct VenueListItem: View {

    let venue: Venue
    var scale: LIST_ITEM_SCALE = .regular
    var onTap: (() -> Void)? = nil

    @State private var showDetail = false
    @State private var showReport = false
    @Environment(SessionStore.self) private var session

    var fieldCityString: String {
        return venue.city + ", " + venue.state
    }

    // MARK: - Scale-derived sizing
    private var imageHeight: CGFloat {
        scale == .regular ? 100 : 80
    }

    private var titleFont: Font {
        scale == .regular ? .headline : .subheadline
    }

    private var subtitleFont: Font {
        scale == .regular ? .body : .subheadline
    }

    /// Height of the bottom info row. Compressed in `.small` so the row
    /// still feels tight under the smaller image.
    private var infoRowHeight: CGFloat {
        scale == .regular ? 45 : 38
    }

    /// Sizing for the directions button glyph — scales down with the
    /// rest of the card so it doesn't visually dominate the small
    /// variant.
    private var directionsGlyph: (width: CGFloat, height: CGFloat) {
        scale == .regular ? (25, 20) : (20, 16)
    }
    
    private var sports: String {
        guard let sport = venue.sports.first else {
            return "\(venue.sports.count) sports"
        }
        // Capitalize just the first letter ("soccer" -> "Soccer") while
        // leaving the rest of the string untouched.
        return sport.prefix(1).uppercased() + sport.dropFirst()
    }

    /// The dot-separated subheader, e.g. "Public • 2 Grass • Lights".
    /// Built from the bits most useful at a glance: access type, the
    /// bookable-unit count + their dominant surface, and whether the venue
    /// is lit. Each piece is only appended when it has a value, so a sparse
    /// venue degrades gracefully (e.g. just "Public").
    private var subheader: String {
        var parts: [String] = []

        parts.append(venue.isPublic() ? "Public" : "Private")

        if !venue.units.isEmpty {
            if let surface = dominantSurface {
                parts.append("\(venue.units.count) \(surface)")
            } else {
                let noun = venue.units.count == 1 ? "Court" : "Courts"
                parts.append("\(venue.units.count) \(noun)")
            }
        }

        if venue.features.illuminated {
            parts.append("Lights")
        }

        return parts.joined(separator: " • ")
    }

    /// Most common surface across the venue's units, formatted for display
    /// ("artificial_grass" → "Artificial Grass"). Returns `nil` when no unit
    /// reports a surface so the subheader can fall back to a court count.
    private var dominantSurface: String? {
        let surfaces = venue.units.map(\.surface).filter { !$0.isEmpty }

        // Tally each surface, then take the most frequent one.
        var counts: [String: Int] = [:]
        for surface in surfaces {
            counts[surface, default: 0] += 1
        }
        guard let raw = counts.max(by: { $0.value < $1.value })?.key else {
            return nil
        }

        // "artificial_grass" -> "Artificial Grass"
        let words = raw.replacingOccurrences(of: "_", with: " ").split(separator: " ")
        return words
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    /// Straight-line distance from the user to the venue, e.g. "1.2 mi".
    /// Returns `nil` when we don't yet have a fix on the user's location so
    /// the bottom row can omit it rather than show a bogus value.
    private var distanceString: String? {
        guard let location = LocationManager.shared.location else { return nil }

        let current = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let target = CLLocation(latitude: venue.location.coordinates[1],
                                longitude: venue.location.coordinates[0])
        let miles = current.distance(from: target) / 1609.344
        return String(format: "%.1f mi", miles)
    }

    /// Bottom-row label: the primary sport, plus distance when available
    /// ("Soccer • 1.2 mi").
    private var sportsAndDistance: String {
        guard let distanceString else { return sports }
        return "\(sports) • \(distanceString)"
    }

    /// Font for the bottom "sport • distance" row. Drops to `.caption` in
    /// `.small` so it stays proportional to the smaller image and title.
    private var detailFont: Font {
        scale == .regular ? .callout : .caption
    }

    /// Diameter of the transit badges, scaled down with the rest of the
    /// card so the stack stays proportional in the `.small` variant.
    private var transitDiameter: CGFloat {
        scale == .regular ? 28 : 22
    }

    var body: some View {
        HStack {
            // MARK: - Image
            Group {
                if let img = venue.images.first,
                   let url = generateImageURL(img) {
                    KFImage(url)
                        .placeholder { ImageLoadingView() }
                        .resizable()
                        .cacheOriginalImage()
                        .setProcessor(venueImageProcessor(size: CGSize(width: 1000, height: 600)))
                        .scaledToFill()
                } else {
                    ImageLoadingFailedView()
                }
            }
            .frame(width: imageHeight, height: imageHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(venue.name)
                        .font(titleFont)
                        .bold()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(subheader)
                        .foregroundColor(.gray)
                        .font(subtitleFont)
                        .lineLimit(1)
                }
                .frame(height: infoRowHeight)
                
             
                HStack {
                    Text(sportsAndDistance)
                        .font(detailFont)
                        .lineLimit(1)

                    Spacer()

                    if !venue.transitLines.isEmpty {
                        TransitStack(transits: venue.transitLines,
                                     diameter: transitDiameter)
                    }
                }
            }.padding(.leading, 10)
        }
        .padding(.vertical, 10)
        .sheet(isPresented: $showDetail) {
            VenueView(venue: venue)
                .presentationDetents([.large])
        }
        .padding(.horizontal, 10)
        .onTapGesture {
            if let onTap {
                onTap()
            } else {
                self.showDetail.toggle()
            }
        }
    }
}

#Preview("Regular") {
    VenueListItem(venue: VENUES[4])
        .environment(SessionStore())
}

#Preview("Small") {
    VenueListItem(venue: VENUES[4], scale: .small)
        .environment(SessionStore())
}
