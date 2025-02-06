//
//  EventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import os
import SwiftUI
import Kingfisher

/// A view that shows an event's data at a glance. A list item.
struct EventListItem: View {
    
    @State var event: Event
    @State private var venues: [Venue] = []
    @State private var status: LOADING_STATE = .loading
    @State private var venueState: LOADING_STATE = .pending
    
    @State private var showDetails = false
    @Environment(SessionStore.self) private var session
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_list_item")
    
    private var title: String {
        guard let title = event.title else {
            return "Event"
        }
        return title
    }
    
    private var imageURL: URL? {
        guard let img = event.imageURL else {
            return nil
        }
        return generateImageURL(img)
    }
    
    private var venueDescriptors: [VenueDescriptor] {
        guard let venues = event.venues else {
            return [VenueDescriptor]()
        }
        return venues
    }
    
    var body: some View {
        Button(action:{ self.showDetails.toggle() }) {
            VStack {
                VStack(alignment: .leading){
                    HStack {
                        KFImage(imageURL)
                            .placeholder {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.gray)
                                    .frame(width: 80, height: 80)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .foregroundStyle(Color("background"))
                                    }
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(radius: 10, corners: .allCorners)
                        VStack(alignment: .leading){
                            Text(title)
                                .font(.custom("Helvetica-Nue", size: 20))
                                .bold()
                                .frame(height: 20)
                                .padding(.top)
                                .foregroundColor(.primary)
                            
                            if venueDescriptors.count > 1 {
                                Text("Multiple Locations")
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .redacted(reason: venueState != .success ? .placeholder : [])
                            } else {
                                if let venue = venues.first {
                                    Text(venue.name)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .redacted(reason: venueState != .success ? .placeholder : [])
                                } else {
                                    if let d = venueDescriptors.first{
                                        Text(d.name)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                            .redacted(reason: venueState != .success ? .placeholder : [])
                                    }
                                }
                            }
                            Spacer()
                            if event.type == EVENT_TYPES.Competitive {
                                Text("Tournament")
                                    .font(.caption)
                                    .padding(.bottom)
                                    .foregroundStyle(Color("color-tert"))
                            }
                        }
                        Spacer()
                        _TrailingView(event: $event)
                    }
                }.padding(.horizontal)
            }.frame(height: 100)
        }
        .clipShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("background"))
        }
        .fullScreenCover(isPresented: $showDetails) {
            EventView(event: event)
                .presentationDetents([.large])
        }
        .task {
            venueState = .loading
            venues = await session.fetchVenues(in: venueDescriptors)
            venueState = .success
        }
    }
}

/// Trailing view for Event view.
/// Contains the start date and time and participants view.
struct _TrailingView: View {
    
    @Binding var event: Event
    @State private var isBlinking: Bool = false
    
    var participantsCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        return participants.count
    }
    
    var minParticipantsCount: Int {
        guard let minParticipants = event.minParticipants else {
            return 0
        }
        return minParticipants
    }
    
    var iconColor: Color {
        if (minParticipantsCount != 0) && (participantsCount != 0) && (participantsCount < minParticipantsCount) {
            return .yellow
        } else {
            return .foreground
        }
    }
    
    var body: some View {
        VStack (alignment: .trailing){
            switch event.getEventStatus() {
            case .pending:
                VStack (alignment: .trailing){
                    Text(event.timeToString())
                        .bold()
                        .font(.callout)
                        .foregroundColor(.primary)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            case .live:
                VStack (alignment: .trailing){
                    HStack {
                        Circle()
                            .frame(width: 10, height: 10)
                            .opacity(isBlinking ? 0 : 1)
                            .transaction { transaction in
                                transaction.animation = .linear(duration: 0.5).repeatForever(autoreverses: true)
                            }
                            .onAppear { isBlinking.toggle() }
                        Text("Live")
                            .bold()
                            .font(.callout)
                    }.foregroundStyle(.red)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            case .ended:
                VStack (alignment: .trailing){
                    HStack {
                        Text("Ended")
                            .bold()
                            .font(.callout)
                    }.foregroundStyle(.gray)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            }
            
            HStack {
                Image(systemName: "person.3.sequence.fill")
                    .foregroundColor(iconColor)
                Text("\(participantsCount)")
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    EventListItem(event: EVENTS[0])
        .environment(SessionStore())
}
