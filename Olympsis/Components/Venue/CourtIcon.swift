//
//  CourtIcon.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/15/26.
//

import SwiftUI

struct CourtIcon: View {
    var color: String
    
    var body: some View {
        Group {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 35, height: 45)
                    .foregroundStyle(Color(hex: color))
                
                Image(systemName: "sportscourt")
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(90))
            }
        }
    }
}

#Preview {
    CourtIcon(color: "#B85B3A")
}
