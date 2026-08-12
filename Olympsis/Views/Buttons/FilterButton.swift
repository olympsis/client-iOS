//
//  FilterButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/30/25.
//

import SwiftUI

struct FilterButton: View {
    
    @Binding var numActive: Int
    var action: () -> Void
    
    var body: some View {
        // Inner button content is identical across OS versions; only the
        // surface treatment (liquid glass vs. material) differs, so we
        // bind it to a `let` and apply the conditional background after.
        let button = Button(action: action) {
            // `ViewThatFits` measures its candidates along the horizontal
            // axis and renders the first one that fits the available width.
            // The full label (marker + "filters" text) is preferred, but on
            // a narrow device — or when the user runs a large system font —
            // it falls back to the marker-only layout instead of letting the
            // text wrap.
            ViewThatFits(in: .horizontal) {
                label(showsText: true)
                label(showsText: false)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }

        if #available(iOS 26.0, *) {
            button
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
        } else {
            button
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    /// The button's inner content. `showsText` controls whether the trailing
    /// "filters" label is included so `ViewThatFits` can pick a compact,
    /// marker-only variant when there isn't room for the text.
    @ViewBuilder
    private func label(showsText: Bool) -> some View {
        HStack(spacing: 5) {
            if (numActive > 0) {
                Text("\(numActive)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 7)
                    .background(Color.blue.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Image(systemName: "line.3.horizontal.decrease")
                    .imageScale(.small)
                    .fontWeight(.medium)
            }

            if showsText {
                Text(String(localized: "filters", table: "General"))
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
}

#Preview {
    FilterButton(numActive: .constant(5), action: {})
}
