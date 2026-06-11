//
//  TransitStack.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/11/26.
//

import SwiftUI

/// A compact, horizontally-overlapping stack of transit-line badges.
///
/// Renders up to `maxVisible` colored line circles; any lines beyond that
/// collapse into a single trailing "+n" overflow badge. Used on
/// `VenueListItem` to surface which transit lines serve a venue without
/// spending a full row per line (that's what `TransitLabel` is for).
struct TransitStack: View {

    let transits: [TransitLine]

    /// Maximum number of line badges drawn before the remainder collapses
    /// into the "+n" overflow badge.
    var maxVisible: Int = 3

    /// Diameter of each circular badge.
    var diameter: CGFloat = 30

    /// How far each badge slides under its left-hand neighbor. Larger
    /// values tighten the stack; it's clamped so badges never fully hide.
    var overlap: CGFloat = 12

    /// The lines actually drawn as colored badges.
    private var visible: [TransitLine] {
        Array(transits.prefix(maxVisible))
    }

    /// Number of lines hidden behind the overflow badge (0 when all fit).
    private var overflow: Int {
        max(0, transits.count - maxVisible)
    }

    var body: some View {
        // Negative spacing pulls each badge under the previous one. We
        // reverse the z-order (see `.zIndex`) so the leading badge sits on
        // top — the conventional "stacked" look, with the "+n" tucked behind.
        HStack(spacing: -overlap) {
            ForEach(Array(visible.enumerated()), id: \.element.id) { index, transit in
                badge(
                    text: transit.name,
                    fill: Color(hex: transit.color),
                    foreground: foreground(for: transit.color)
                )
                .zIndex(Double(visible.count - index))
            }

            if overflow > 0 {
                badge(
                    text: "+\(overflow)",
                    fill: Color(.systemGray3),
                    foreground: .primary
                )
            }
        }
    }

    /// One circular badge with a background-colored ring so overlapping
    /// neighbors stay visually separated.
    private func badge(text: String, fill: Color, foreground: Color) -> some View {
        ZStack {
            Circle()
                .fill(fill)
                .overlay(
                    Circle().stroke(Color(.systemBackground), lineWidth: 2)
                )

            Text(text)
                .font(.system(size: diameter * 0.42, weight: .bold))
                .foregroundStyle(foreground)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal, 2)
        }
        .frame(width: diameter, height: diameter)
    }

    /// Pick black or white text based on the perceived brightness of the
    /// line color. Mirrors `TransitLabel.foreground`: Rec. 601 luma with a
    /// 0.6 threshold (keeps MTA yellow lines on black, saturated reds /
    /// greens / blues on white). Falls back to white on a parse failure.
    private func foreground(for color: String) -> Color {
        let hex = color.replacingOccurrences(of: "#", with: "")
        guard hex.count == 6, let rgb = UInt32(hex, radix: 16) else {
            return .white
        }
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8)  & 0xFF) / 255.0
        let b = Double( rgb        & 0xFF) / 255.0
        let luma = 0.299 * r + 0.587 * g + 0.114 * b
        return luma > 0.6 ? .black : .white
    }
}

#Preview("Overflow") {
    let lines = [
        TransitLine(id: "1", type: "subway", name: "1", system: "MTA", color: "#EE352E", iconURL: "", locality: "", administrativeArea: "", countryCode: ""),
        TransitLine(id: "Q", type: "subway", name: "Q", system: "MTA", color: "#FCCC0A", iconURL: "", locality: "", administrativeArea: "", countryCode: ""),
        TransitLine(id: "A", type: "subway", name: "A", system: "MTA", color: "#0039A6", iconURL: "", locality: "", administrativeArea: "", countryCode: ""),
        TransitLine(id: "G", type: "subway", name: "G", system: "MTA", color: "#6CBE45", iconURL: "", locality: "", administrativeArea: "", countryCode: ""),
        TransitLine(id: "L", type: "subway", name: "L", system: "MTA", color: "#A7A9AC", iconURL: "", locality: "", administrativeArea: "", countryCode: ""),
    ]
    TransitStack(transits: lines)
}

#Preview("Fits") {
    let lines = [
        TransitLine(id: "1", type: "subway", name: "1", system: "MTA", color: "#EE352E", iconURL: "", locality: "", administrativeArea: "", countryCode: ""),
        TransitLine(id: "3", type: "subway", name: "3", system: "MTA", color: "#EE352E", iconURL: "", locality: "", administrativeArea: "", countryCode: ""),
    ]
    TransitStack(transits: lines)
}
