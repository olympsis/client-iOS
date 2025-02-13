//
//  SquareIconButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/21/24.
//

import SwiftUI

struct SquareIconButton: View {
    
    var icon: Image
    var text: String
    var size: CGSize = .init(width: 100, height: 100)
    var imageSize: CGSize = .init(width: 50, height: 50)
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.Background.primary)
                        .frame(width: size.width, height: size.height)
                    icon
                        .resizable()
                        .foregroundStyle(Color.foreground)
                        .frame(width: imageSize.width, height: imageSize.height)
                }
                
                Text(text)
                    .font(.caption)
                    .foregroundStyle(Color.foreground)
            }
        }
    }
}

#Preview {
    SquareIconButton(icon: Image(systemName: "photo"), text: "Export", imageSize: CGSize(width: 45, height: 35), action: {})
}
