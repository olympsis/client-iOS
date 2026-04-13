//
//  EventSmallListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/12/24.
//

import SwiftUI
import Kingfisher

struct EventSmallListItem: View {
    
    @State var event: Event
    
    private var title: String {
        return event.title
    }
    
    private var imageURL: URL? {
        return generateImageURL(event.mediaURL)
    }
    
    private var fieldName: String {
        
        return ""
    }
    
    var participantsCount: Int {
        return event.participants.count
    }
    
    var minParticipantsCount: Int {
        guard let minParticipants = event.participantsConfig?.minParticipants else {
            return 0
        }
        return Int(minParticipants)
    }
    
    var iconColor: Color {
        if (minParticipantsCount != 0) && (participantsCount != 0) && (participantsCount < minParticipantsCount) {
            return .yellow
        } else {
            return Color("color-prime")
        }
    }
    
    var body: some View {
        HStack {
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
                .cornerRadius(radius: 10, corners: .allCorners)
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(event.timeToString() + " at " + event.getStartHourAndMinute())
                    .font(.callout)
                    .foregroundStyle(.gray)
                
            }
            
            Spacer()
        }
        .padding()
        .clipShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color(Color.Background.secondary))
        }
        .overlay(alignment: .bottomTrailing) {
            if event.participants.count > 0 {
                HStack {
                    Image(systemName: "person.3.fill")
                    Text("\(event.participants.count)")
                        .font(.callout)
                }
                .padding()
                .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    EventSmallListItem(event: EVENTS[0])
        .environment(SessionStore())
}
