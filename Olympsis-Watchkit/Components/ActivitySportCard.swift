//
//  SportActivityCard.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/20/25.
//

import SwiftUI

struct ActivitySportCard: View {
    
    var sport: SUPPORTED_SPORTS
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundStyle(Color.Brand.primary)
            .overlay {
                VStack(alignment: .center) {
                    sport.icon()
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.primary)
                    
                    Text(sport.getName())
                        .italic()
                        .textCase(.uppercase)
                        .font(.custom("Archivo-Italic", size: 15, relativeTo: .title3))
                }.padding(.vertical, 30)
            }
    }
}

#Preview {
    ActivitySportCard(sport: .basketball)
}
