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
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: SCREEN_WIDTH*2, height: 250*2)))
                    .frame(width: SCREEN_WIDTH, height: 250)
            } else {
                Rectangle()
                    .foregroundStyle(.gray)
                    .frame(width: SCREEN_WIDTH, height: 250)
                    .overlay {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(Color(Color.Background.secondary))
                            .imageScale(.large)
                    }
            }
            
            VStack {
                Spacer()
                HStack {
                    if let logoURL = logo {
                        KFImage(logoURL)
                            .resizable()
                            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 200, height: 200)))
                            .frame(width: 100, height: 100)
                            .border(Color(Color.Background.secondary), width: 3)
                    } else {
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.gray)
                            .border(Color(Color.Background.secondary), width: 3)
                            .overlay {
                                Image(systemName: "person.3.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(Color(Color.Background.secondary))
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
