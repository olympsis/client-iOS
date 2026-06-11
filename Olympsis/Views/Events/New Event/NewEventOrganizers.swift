//
//  NewEventOrganizers.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/25/26.
//

import SwiftUI

struct NewEventOrganizers: View {
    
    @State var manager: NewEventManager
    
    var posterURL: URL? {
        guard let poster = manager.poster,
              let imgURL = poster.imageURL else { return nil }
        return generateImageURL(imgURL)
    }
    
    var posterName: String {
        guard let poster = manager.poster else { return "John Doe" }
        let first = poster.firstName
        let last = poster.lastName
        switch (first, last) {
            case let (f?, l?): return "\(f) \(l)"
            case let (f?, nil): return f
            case let (nil, l?): return l
            default: return "John Doe"
        }
    }
    
    var posterUsername: String {
        guard let poster = manager.poster,
              let username = poster.username else { return "@johndoe" }
        return username
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "hosted-title", table: "Events"))
                .font(.headline)
                .bold()
            
            //MARK: - Poster
            HStack {
                UserBadgeView(size: .small, imageURL: posterURL)
                
                VStack(alignment: .leading) {
                    Text(posterName)
                        .font(.callout)
                        .fontWeight(.bold)
                    Text(posterUsername)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            
            //MARK: - Organizers
            if !manager.organizers.isEmpty {
                Text(String(localized: "new-event-organizer-title", table: "Events"))
                    .font(.headline)
                    .bold()
            }
            
            //MARK: - Sponsors
            if !manager.sponsors.isEmpty {
                Text(String(localized: "sponsors-title", table: "Events"))
                    .font(.headline)
                    .bold()
            }
            
//            HStack {
//                Button(action: {}) {
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(height: 50)
//                        .foregroundStyle(Color.Background.secondary)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.Foreground.default.opacity(0.2), lineWidth: 1)
//                        }
//                        .overlay {
//                            Text("Add an organizer")
//                        }
//                }
//                
//                
//                
//                Button(action: {}) {
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(height: 50)
//                        .foregroundStyle(Color.Background.secondary)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.Foreground.default.opacity(0.2), lineWidth: 1)
//                        }
//                        .overlay {
//                            Text("Add a sponsor")
//                        }
//                }
//            }
        }
    }
}

#Preview {
    NewEventOrganizers(manager: NewEventManager())
}
