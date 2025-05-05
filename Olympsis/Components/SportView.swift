//
//  SportView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI


/// A view to visualize a sport by it's associated icon and name
struct SportView: View {
    
    var sport: Sport
    
    private var name: String {
        var text = sport.name
        if let firstIndex = text.firstIndex(where: { $0.isLetter }) {
            text.replaceSubrange(firstIndex...firstIndex, with: text[firstIndex].uppercased())
        }
        
        return text
    }
    
    var body: some View {
        VStack {
            Text(name)
                .padding(5)
                .padding(.trailing, 5)
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
    SportView(sport: Sport(name: "🎾 tennis", images: []))
}
