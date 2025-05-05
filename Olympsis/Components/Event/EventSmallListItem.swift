//
//  EventSmallListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/12/24.
//

import SwiftUI

struct EventSmallListItem: View {
    
    @State var event: Event
    @State private var showDetails: Bool = false
    
    private var title: String {
        return event.title
    }
    
    private var imageURL: String {
        return event.mediaURL
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
            Image(imageURL)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(radius: 10, corners: .allCorners)
            
            VStack(alignment: .leading) {
                Text(title)
                    
                Text(fieldName)
                    .foregroundStyle(.gray)
                    .font(.caption)
                
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "person.3.sequence.fill")
                    .foregroundColor(iconColor)
                    .imageScale(.small)
                Text("\(participantsCount)")
                    .foregroundColor(.primary)
                    .font(.caption)
            }.padding(.trailing)
        }.clipShape(Rectangle())
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(Color.Background.secondary))
            }
        .padding(.horizontal)
            .onTapGesture {
                self.showDetails.toggle()
            }
            .fullScreenCover(isPresented: $showDetails) {
                EventView(event: event)
                    .presentationDetents([.large])
            }
    }
}

#Preview {
    EventSmallListItem(event: EVENTS[0])
        .environment(SessionStore())
}
