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
    var scale: SCALE
    
    var body: some View {
        VStack {
            Text("TODO")
        }
    }
}

#Preview {
    SportView(sport: Sport(name: "🎾 tennis", images: []), scale: .Medium)
}
