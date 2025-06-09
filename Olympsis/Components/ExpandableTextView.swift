//
//  ExpandableTextView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/9/25.
//

import SwiftUI

struct ExpandableTextView: View {
    let text: String
        let maxLines: Int
        @State private var isExpanded = false
        @State private var isTruncatable = false
        @State private var hasCheckedTruncation = false
        
        init(text: String, maxLines: Int = 5) {
            self.text = text
            self.maxLines = maxLines
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(text)
                    .lineLimit(isExpanded ? nil : maxLines)
                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    .background(
                        // Only check truncation once when view first appears
                        Group {
                            if !hasCheckedTruncation {
                                ViewThatFits(in: .vertical) {
                                    Text(text)
                                        .hidden()
                                        .onAppear {
                                            isTruncatable = false
                                            hasCheckedTruncation = true
                                        }
                                    
                                    Text(text)
                                        .lineLimit(maxLines)
                                        .hidden()
                                        .onAppear {
                                            isTruncatable = true
                                            hasCheckedTruncation = true
                                        }
                                }
                            }
                        }
                    )
                
                if isTruncatable {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text(isExpanded ? "Show less" : "Show more")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
}

#Preview {
    ExpandableTextView(text: CLUBS[0].description ?? "")
}
