//
//  TransitLabel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/15/26.
//

import SwiftUI

struct TransitLabel: View {

    var transit: TransitLine

    /// Pick black or white based on the perceived brightness of the line
    /// color. Uses Rec. 601 luma (same formula browsers use for
    /// `grayscale()`); the 0.6 threshold keeps the MTA yellow lines
    /// (Q/N/R/W) on black text while red / green / blue stay on white.
    /// Falls back to white when the hex fails to parse — matches the
    /// most common case of saturated brand colors.
    private var foreground: Color {
        let hex = transit.color
            .replacingOccurrences(of: "#", with: "")
        guard hex.count == 6, let rgb = UInt32(hex, radix: 16) else {
            return .white
        }
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8)  & 0xFF) / 255.0
        let b = Double( rgb        & 0xFF) / 255.0
        let luma = 0.299 * r + 0.587 * g + 0.114 * b
        return luma > 0.6 ? .black : .white
    }

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(hex: transit.color))
                    .frame(width: 35, height: 35)

                Text(transit.name)
                    .fontWeight(.bold)
                    .foregroundStyle(foreground)
            }
            
            HStack(alignment: .top) {
                Text(transit.type.prefix(1).uppercased())
                +
                Text(transit.type.dropFirst(1))
                Text(transit.system)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    let transit = TransitLine(id: UUID().uuidString, type: "subway", name: "Q", system: "MTA", color: "#FCCC0A", iconURL: "", locality: "", administrativeArea: "", countryCode: "")
    TransitLabel(transit: transit)
}
