//
//  ClubBanner.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/24.
//

import SwiftUI
import Kingfisher

struct ClubLogoBanner: View {
        
    private var logo: URL? {
        guard let logo = club.logo else {
            return nil
        }
        return URL(string: GenerateImageURL(logo))
    }
    
    private var banner: URL? {
        guard let banner = club.banner else {
            if let rand = defaultClubImageURLS.randomElement() {
                return URL(string: GenerateImageURL(rand))
            }
            return nil
        }
        return URL(string: GenerateImageURL(banner))
    }
    
    private let gradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: Color.gray, location: 0.4),
            .init(color: Color.gray, location: 0.8),
            .init(color: Color.gray, location: 1)
        ]),
        startPoint: .bottom,
        endPoint: .top
    )
    
    @Environment(Club.self) private var club
    
    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if let bannerURL = banner {
                    KFImage(bannerURL)
                        .resizable()
                        .setProcessor(DownsamplingImageProcessor(size: CGSize(width: SCREEN_WIDTH*2, height: 250*2)))
                        .frame(width: SCREEN_WIDTH, height: 200)
                } else {
                    Rectangle()
                        .foregroundStyle(Color.Background.secondary)
                        .frame(width: SCREEN_WIDTH, height: 200)
                        .overlay {
                            Image(systemName: "photo.fill")
                                .imageScale(.large)
                        }
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
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(Color.Background.secondary, lineWidth: 3)
                            }
                    } else {
                        Circle()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(Color.Background.secondary)
                            .overlay {
                                Image(systemName: "person.3.fill")
                                    .imageScale(.large)
                            }
                            .overlay {
                                Circle()
                                    .stroke(Color.primary.opacity(0.3), lineWidth: 3)
                            }
                    }
                    Spacer()
                }.padding(.horizontal)
            }
        }
        .frame(height: 250)
        .overlay(alignment: .topLeading) {
            if (!club.sports.isEmpty) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(club.sports, id: \.self) { sport in
                            HStack {
                                Text(sport.replacingOccurrences(of: "-", with: " ").capitalized)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding([.leading, .trailing], 2.5)
                            }
                            .padding(5)
                            .modifier(SmallPillModifier())
                        }
                    }
                }
                .padding(5)
                .background {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.95)
                        .mask(gradient)
                }
            }
        }
    }
}

#Preview {
    ClubLogoBanner()
        .environment(CLUBS[1])
}
