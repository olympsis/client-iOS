//
//  CircularChip.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/11/26.
//

import SwiftUI

/// 44×44 round button  Glass on iOS 26+, `.regularMaterial` fallback below that.
struct CircularChip: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                Image(systemName: systemImage)
                    .imageScale(.medium)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.regular.interactive(), in: .circle)
        } else {
            Button(action: action) {
                Image(systemName: systemImage)
                    .imageScale(.medium)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
            }
        }
    }
}

#Preview {
    CircularChip(systemImage: "magnifyingglass", action: {})
}
