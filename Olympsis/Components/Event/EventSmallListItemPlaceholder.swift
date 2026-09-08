//
//  EventSmallListItemPlaceholder.swift
//  Olympsis
//
//  Skeleton placeholder shown in a list while `EventSmallListItem` data is
//  loading. Mirrors the real item's layout — a 100x100 image on the leading
//  edge with a type / title / time stack beside it — but renders the text
//  through `.redacted(reason: .placeholder)` so it reads as a gray loading
//  template instead of real data.
//

import SwiftUI

struct EventSmallListItemPlaceholder: View {

    var body: some View {
        HStack(alignment: .top) {
            // Stands in for the KFImage in the real item. Only the leading
            // corners are rounded so it tucks into the card background the
            // same way the loaded image does.
            Rectangle()
                .foregroundStyle(.gray)
                .opacity(0.3)
                .frame(width: 100, height: 100)
                .cornerRadius(radius: 10, corners: [.topLeft, .bottomLeft])

            // Sample strings are never read by the user — they exist purely
            // to give the redacted bars the same footprint as real content.
            VStack(alignment: .leading) {
                Text("PICK UP")
                    .font(.caption2)
                    .fontWeight(.medium)

                Text("Example Event Title")
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                Text("Today at 5:30 PM")
                    .font(.caption)
            }
            .foregroundStyle(.primary)
            .padding(.top, 5)
            .padding(.leading, 5)
            .redacted(reason: .placeholder)

            Spacer()
        }
        .clipShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color(Color.Background.secondary))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.border, lineWidth: 1)
                }
        }
    }
}

#Preview {
    VStack {
        EventSmallListItemPlaceholder()
        EventSmallListItemPlaceholder()
    }
    .padding(.horizontal)
}
