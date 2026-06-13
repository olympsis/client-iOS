//
//  EventListItemTemplate.swift
//  Olympsis
//
//  Skeleton placeholder shown while the events explorer is loading.
//  Mirrors the rough shape of `EventListItem` — an image card with a
//  title / location / sport stack pinned to the bottom — but renders it
//  all through `.redacted(reason: .placeholder)` so it reads as a gray
//  loading template instead of real data.
//

import SwiftUI

struct EventListItemTemplate: View {

    /// Matches `EventListItem`'s scale so the skeleton lines up with the
    /// real cards that replace it (the iPad split layout passes `.small`).
    var scale: LIST_ITEM_SCALE = .regular

    private var imageHeight: CGFloat {
        scale == .regular ? 250 : 180
    }

    private var titleFont: Font {
        scale == .regular ? .title3 : .headline
    }

    private var locationFont: Font {
        scale == .regular ? .body : .subheadline
    }

    var body: some View {
        // The gray rounded rectangle stands in for the event image; the
        // text block at the bottom mirrors the type / title / location
        // overlay so the placeholder occupies the same footprint as a
        // loaded `EventListItem`.
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.gray)
            .opacity(0.3)
            .frame(height: imageHeight)
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PICK UP")
                        .font(.caption)
                        .fontWeight(.medium)

                    Text("Example Event Title")
                        .font(titleFont)
                        .fontWeight(.bold)

                    Text("at Example Venue Name")
                        .font(locationFont)
                }
                .foregroundColor(.primary)
                .padding()
            }
            .redacted(reason: .placeholder)
    }
}

#Preview {
    VStack {
        EventListItemTemplate()
        EventListItemTemplate(scale: .small)
    }
    .padding(.horizontal)
}
