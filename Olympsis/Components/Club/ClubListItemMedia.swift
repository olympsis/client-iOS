//
//  ClubListItemMedia.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI
import Kingfisher

struct ClubListItemMedia: View {
    
    var club: Club
    var logoURL: URL? {
        guard let logo = club.logo else {
            return nil
        }
        return URL(string: GenerateImageURL(logo))
    }
    
    var bannerURL: URL? {
        guard let banner = club.banner else {
            if let rand = defaultClubImageURLS.randomElement() {
                return URL(string: GenerateImageURL(rand))
            }
            return nil
        }
        return URL(string: GenerateImageURL(banner))
    }
    
    var clubSports: [String] {
        return club.sports.map { $0.prefix(1).capitalized + $0.dropFirst() }
    }
    
    var membersCount: String {
        return String(localized: "\(club.members.count) member", table: "General")
    }
    
    private let gradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: Color.gray, location: 0.4),
            .init(color: Color.gray, location: 0.8),
            .init(color: Color.gray, location: 1)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        KFImage(bannerURL)
            .placeholder {
                Circle()
                    .foregroundStyle(Color.Background.secondary)
                    .overlay(alignment: .center) {
                        Image(systemName: "photo")
                            .imageScale(.large)
                    }
            }
            .resizable()
            .scaledToFill()
            .frame(height: 150)
            .clipped()
            .overlay(alignment: .topLeading) {
                KFImage(logoURL)
                    .placeholder {
                        Circle()
                            .foregroundStyle(Color.Background.tertiary)
                            .overlay(alignment: .center) {
                                Image(systemName: "person.2.fill")
                                    .imageScale(.large)
                            }
                    }
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 70, height: 70)
                    .overlay {
                        Circle()
                            .stroke(.thinMaterial, lineWidth: 5)
                    }
                    .clipShape(Circle())
                    .padding()
            }
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(clubSports, id: \.self) { sport in
                                HStack {
                                    Text(sport)
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
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .imageScale(.small)
                            .foregroundStyle(.white)
                        
                        Text(membersCount)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.trailing, 2.5)
                    }
                    .padding(5)
                    .modifier(SmallPillModifier())
                }
                .padding(.bottom, 4)
                .padding(.horizontal, 5)
                .background {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.95)
                        .mask(gradient)
                }
            }
    }
}

#Preview {
    ClubListItemMedia(club: CLUBS[1])
}
