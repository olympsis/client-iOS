//
//  BasicButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/12/26.
//

import SwiftUI

struct BasicButtonLabel: View {
    
    var text: String
    var color: Color
    
    var body: some View {
        Text(text)
            .font(.callout)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(color)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            }
    }
}

#Preview {
    BasicButtonLabel(text: "View more", color: Color.Background.primary)
}
