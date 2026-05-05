//
//  VenueListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI
import Kingfisher

struct VenueListItem: View {

    // `Venue` is a reference type — a plain `let` avoids the per-row
    // `@State` storage allocation and we never reassign it locally.
    let venue: Venue
    /// Mirrors `EventListItem.scale` so a single value threaded through
    /// `ExplorerList` controls both card sizes consistently in split view.
    var scale: LIST_ITEM_SCALE = .regular
    /// When provided, tapping the card runs this closure instead of
    /// presenting the local `showDetail` sheet — used by `ExplorerList`
    /// to push onto the shared `EventRouter` from inside the bottom
    /// sheet (where a sheet-on-sheet would be jank).
    var onTap: (() -> Void)? = nil

    @State private var showDetail = false // show field view detail
    @State private var showReport = false // show make a report view
    @Environment(SessionStore.self) private var session

    var fieldCityString: String {
        return venue.city + ", " + venue.state
    }

    func leadToMaps() {
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(venue.location.coordinates[1]),\(venue.location.coordinates[0])")! as URL)
    }

    // MARK: - Scale-derived sizing
    //
    // Mirrors the values used by `EventListItem` so the two list items
    // line up when shown side by side. The image fills the available
    // width (no hardcoded pixel width) and just controls its height.

    private var imageHeight: CGFloat {
        scale == .regular ? 250 : 180
    }

    private var titleFont: Font {
        scale == .regular ? .title2 : .headline
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

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Image
            Group {
                if let img = venue.images.first,
                   let url = generateImageURL(img) {
                    KFImage(url)
                        .placeholder { ImageLoadingView() }
                        .resizable()
                        .cacheOriginalImage()
                        // Match `EventListItem`: fill the column, crop to
                        // the configured height. The processor is sized
                        // generously enough for the regular variant and
                        // re-used for `.small` (Kingfisher will downscale).
                        .setProcessor(venueImageProcessor(size: CGSize(width: 1000, height: 600)))
                        .scaledToFill()
                } else {
                    ImageLoadingFailedView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: imageHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // MARK: - Bottom info row (kept under the image, scales down)
            HStack {
                VStack(alignment: .leading) {
                    Text(venue.name)
                        .font(titleFont)
                        .bold()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(fieldCityString)
                        .foregroundColor(.gray)
                        .font(subtitleFont)
                        .lineLimit(1)
                }.frame(height: infoRowHeight)

                Spacer()

                Button(action: { leadToMaps() }) {
                    Image(systemName: "car")
                        .resizable()
                        .frame(width: directionsGlyph.width, height: directionsGlyph.height)
                        .foregroundColor(.primary)
                        .imageScale(.large)
                }.frame(height: 40)
            }
            .padding(.top, 10)
            .padding(.horizontal)
            .sheet(isPresented: $showDetail) {
                VenueView(venue: venue)
                    .presentationDetents([.large])
            }
        }
        
        .padding(.horizontal, 10)
        .onTapGesture {
            // Router-driven navigation wins over the local sheet when
            // a caller has wired one up (see `ExplorerList`).
            if let onTap {
                onTap()
            } else {
                self.showDetail.toggle()
            }
        }
    }
}

#Preview("Regular") {
    VenueListItem(venue: VENUES[0])
        .environment(SessionStore())
}

#Preview("Small") {
    VenueListItem(venue: VENUES[0])
        .environment(SessionStore())
}
