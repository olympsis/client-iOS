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
            TextField("Search...", text: $text, onCommit: onCommit)
                .foregroundColor(.primary)
                .keyboardType(.webSearch)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10.0)
    }
}

