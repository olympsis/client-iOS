//
//  EventMedia.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI
import Kingfisher

struct EventMedia: View {
    
    var event: Event
    
    private var mediaURL: URL? {
        return generateImageURL(event.mediaURL)
    }
    
    private let gradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: Color.gray.opacity(0.5), location: 0.4),
            .init(color: Color.gray.opacity(0.85), location: 0.8),
            .init(color: Color.gray, location: 1)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    private var tags: [String] {
        var arr = [String]()
        
        // Smarter ranking in the future
        
        // If tournament add tag here
        if let isTournament = event.formatConfig?.isCompetition {
            if isTournament {
                arr.append("tournament")
            }
        }
        
        // Event sports tags
        arr.append(contentsOf: event.sports)
        
        // Event tags
        arr.append(contentsOf: event.tags)
        
        return arr
    }
    
    var body: some View {
        KFImage(mediaURL)
            .placeholder {
                Rectangle()
                    .frame(height: SCREEN_WIDTH)
                    .foregroundStyle(.gray)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(Color.Foreground.default)
                    }
            }
            .resizable()
            .scaledToFill()
            .frame(height: SCREEN_WIDTH)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .bottomLeading) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag.prefix(1).capitalized + tag.dropFirst())
                                .padding(5)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 5)
                                .foregroundStyle(Color.white)
                                .background(
                                    Color.black
                                        .opacity(0.21)
                                )
                                .border(Color.black.opacity(0.15), width: 1)
                                .clipShape(Capsule())
                                
                        }
                    }
                }
                .padding([.leading, .bottom], 5)
                .background {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.85)
                        .mask(gradient)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
    }
}

#Preview {
    EventMedia(event: EVENTS[0])
}
