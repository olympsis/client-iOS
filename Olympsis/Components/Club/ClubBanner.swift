//
//  ClubBanner.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/24.
//

import SwiftUI
import Kingfisher

struct ClubBanner: View {
    
    var logo: URL? {
        guard let logo = club.logo else {
            return nil
        }
        return URL(string: GenerateImageURL(logo))
    }
    
    var banner: URL? {
        guard let banner = club.banner else {
            return nil
        }
        return URL(string: GenerateImageURL(banner))
    }
    
    @EnvironmentObject private var club: Club
    
    var body: some View {
        ZStack(alignment: .top) {
            if let bannerURL = banner {
                KFImage(bannerURL)
                    .resizable()
                    .frame(width: SCREEN_WIDTH, height: 250)
            } else {
                Rectangle()
                    .foregroundStyle(.gray)
                    .frame(width: SCREEN_WIDTH, height: 250)
                    .overlay {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(Color("background"))
                            .imageScale(.large)
                    }
            }
            
            VStack {
                Spacer()
                HStack {
                    if let logoURL = logo {
                        KFImage(logoURL)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .border(Color("background"), width: 3)
                    } else {
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.gray)
                            .border(Color("background"), width: 3)
                            .overlay {
                                Image(systemName: "person.3.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(Color("background"))
                            }
                    }
                    Spacer()
                }.padding(.horizontal)
            }
        }
        .frame(height: 300)
    }
}

#Preview {
    ClubBanner()
        .environmentObject(CLUBS[1])
}
