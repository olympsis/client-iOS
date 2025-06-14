//
//  TagView.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/1/24.
//

import SwiftUI


/// A view to visualize a sport by it's associated icon and name
struct TagView: View {
    
    var tag: Tag
    
    private var name: String {
        return tag.name.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    var body: some View {
        VStack {
            Text(name)
                .padding(5)
                .padding(.horizontal, 5)
                .background(Color.Background.secondary)
                .overlay(
                    Capsule()
                        .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                        .opacity(0.15)
                )
                .clipShape(Capsule())
                
        }
    }
}

#Preview {
    TagView(tag: Tag(name: "beginner-friendly"))
}
