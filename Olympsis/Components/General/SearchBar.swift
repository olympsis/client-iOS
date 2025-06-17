//
//  SearchBar.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI
import Foundation

struct SearchBar: View {
    @Binding var text: String
    var onCommit: () -> Void = {}

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("\(String(localized: "search", table: "General"))...", text: $text, onCommit: onCommit)
                .foregroundColor(.primary)
                .keyboardType(.webSearch)
                .submitLabel(.search)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .cornerRadius(radius: 10, corners: .allCorners)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
        }
    }
}

#Preview {
    SearchBar(text: .constant(""))
        .padding(.horizontal)
}
