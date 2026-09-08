//
//  EventSmallListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/12/24.
//

import SwiftUI
import Kingfisher

struct EventSmallListItem: View {
    
    var event: Event
    
    private var type: String {
        guard let isTournament = event.formatConfig?.isCompetition else {
            return "PICKUP"
        }
        return isTournament ? "TOURNAMENT" : "PICK UP"
    }
    
    private var imageURL: URL? {
        return generateImageURL(event.mediaURL)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            KFImage(imageURL)
                .placeholder {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(Color(Color.Background.secondary))
                        }
                }
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(radius: 10, corners: [.topLeft, .bottomLeft])
            
            VStack(alignment: .leading) {
                Text(type)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.Foreground.yellow)
                
                Text(event.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                Text(event.timeToString() + " at " + event.getStartHourAndMinute())
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(.top, 5)
            .padding(.leading, 5)
            
            Spacer()
        }
        .clipShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color(Color.Background.secondary))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.border, lineWidth: 1)
                }
        }
        .overlay(alignment: .bottomTrailing) {
            ParticipantsStack(participants: event.participants, diameter: 25)
                .padding([.bottom, .trailing], 8)
        }
    }
}

#Preview {
    EventSmallListItem(event: EVENTS[0])
        .padding(.horizontal)
}
