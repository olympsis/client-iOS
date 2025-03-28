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
            return nil
        }
        return URL(string: GenerateImageURL(banner))
    }
    
    var clubSports: [String] {
        return club.sports.map { $0.prefix(1).capitalized + $0.dropFirst() }
    }
    
    var membersCount: String {
        return club.members.count > 1 ? "\(club.members.count) Members" : "\(club.members.count) Member"
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
                Rectangle()
                    .foregroundStyle(Color.Background.secondary)
                    .overlay(alignment: .center) {
                        Image(systemName: "photo")
                            .imageScale(.large)
                    }
            }
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .overlay(alignment: .topLeading) {
                KFImage(logoURL)
                    .placeholder {
                        Rectangle()
                            .foregroundStyle(Color.Background.tertiary)
                            .overlay(alignment: .center) {
                                Image(systemName: "person.2.fill")
                                    .imageScale(.large)
                            }
                    }
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 80, height: 80)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.thinMaterial, lineWidth: 5)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
                                .background(
                                    Color.black
                                        .opacity(0.21)
                                )
                                .border(Color.black.opacity(0.15), width: 1)
                                .clipShape(Capsule())
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
                    .background(
                        Color.black
                            .opacity(0.21)
                    )
                    .border(Color.black.opacity(0.15), width: 1)
                    .clipShape(Capsule())
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
    ClubListItemMedia(club: CLUBS[0])
}
