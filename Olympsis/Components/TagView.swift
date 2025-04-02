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
                .background(
                    Color.gray
                        .opacity(0.21)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )
                .clipShape(Capsule())
                
        }
    }
}

#Preview {
    TagView(tag: Tag(name: "beginner-friendly"))
}
