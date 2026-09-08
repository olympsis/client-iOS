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
    var backgroundColor: Color = Color.Background.secondary
    
    private var name: String {
        return tag.name.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    var body: some View {
        VStack {
            Text(name)
                .padding()
                .padding(.horizontal, 5)
                .background(backgroundColor)
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
