//
//  ClubLogo.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/27/24.
//

import SwiftUI
import Kingfisher

struct ClubLogo: View {
    
    var club: Club
    var logoURL: URL? {
        guard let logo = club.logo else {
            return nil
        }
        return URL(string: GenerateImageURL(logo))
    }
    
    var body: some View {
        if let url = logoURL {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100, alignment: .center)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 100, height: 100)
                .foregroundStyle(.gray)
                .opacity(0.5)
                .overlay {
                    Image(systemName: "person.3.fill")
                        .foregroundStyle(Color("foreground"))
                        .imageScale(.large)
                }
        }
    }
}

#Preview {
    ClubLogo(club: CLUBS[0])
}
