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
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_list_item")
    
    /// Compute wether or not we can allow the users to see the locations
    /// If hide participants is set to true then we only show the locations when the user has RSVPed
    private var canShowLocation: Bool {
        guard let user = session.user,
              user.userID != event.poster?.userID,
              let config = event.config,
              let hideLocation = config.hideLocation else {
            return true
        }
        
        // Reveal after user has RSVPed
        guard event.participants.first(where: { $0.user?.userID == user.userID }) != nil else {
            return !hideLocation
        }
        return true
    }
    
    private var imageURL: URL? {
        return generateImageURL(event.mediaURL)
    }
    
    private var venueLocationName: String {
        guard let first = event.venues.first,
              let name = first.name else {
            guard let venue = venues.first else {
                return "Custom Location";
            }
            
            return venue.name
        }
        
        return name
    }
    
    private var eventSport: String {
        guard let sport = event.sports.first else {
            return "Activity"
        }
        return sport.prefix(1).capitalized + sport.dropFirst()
    }
    
    var body: some View {
        NavigationLink(destination: EventView(event: event).environment(event).environment(session)) {
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
                .clipped()
                .zIndex(1)
                .frame(height: 250)
                .overlay(alignment: .bottom) {
                    VStack(spacing: 5) {
                        Spacer()
                        HStack {
                            
                            // MARK: - Title and Location
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Text("\(String(localized: "event-at-location", table: "Events")) \(venueLocationName)")
                                    .font(.body)
                                    .opacity(0.8)
                                    .foregroundStyle(.white)
                                    .redacted(reason: canShowLocation ? [] : .placeholder)
                            }
                            
                            Spacer()
                            
                            // MARK: - Participants
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .imageScale(.small)
                                    .foregroundStyle(.white)
                                
                                Text("\(event.participants.count) \(String(localized: "event-participants", table: "Events"))")
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
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            }
                            .offset(x: 2, y: 8)
                        }
                        
                        HStack(alignment: .center, spacing: 5) {
                            
                            // MARK: - Date
                            HStack {
                                Image(systemName: "calendar")
                                    .imageScale(.small)
                                    .foregroundStyle(.white)
                                Text(event.timeToString())
                                    .font(.callout)
                                    .foregroundStyle(.white)
                            }
                            
                            Spacer()

                            // MARK: - Competition Tag
                            if event.isCompetition() {
                                HStack {
                                    Text(String(localized: "event-tournament", table: "Events"))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding([.leading, .trailing], 2.5)
                                        .foregroundStyle(Color.Brand.quaternary)
                                }
                                .padding(5)
                                .background(
                                    Color.black
                                        .opacity(0.21)
                                )
                                .border(Color.black.opacity(0.15), width: 1)
                                .clipShape(Capsule())
                            }
                            
                            
                            // MARK: - Primary Sport Tag
                            HStack {
                                Text(eventSport)
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
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            }
                            
                            // MARK: - Start Time
                            HStack {
                                Image(systemName: "clock")
                                    .imageScale(.small)
                                    .foregroundStyle(.white)
                                Text(event.getStartHourAndMinute())
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
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            }
                        }
                    }
                    .padding([.leading, .trailing], 7)
                    .padding(.bottom, 6)
                    .frame(height: 100)
                    .background {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.95)
                            .mask(gradient)
                    }
                }.clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .task {
            // Skip fetch if venue names are already available on the event
            guard event.venues.first?.name == nil else {
                venueState = .success
                return
            }
            venueState = .loading
            venues = await session.fetchVenues(in: event.venues)
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
                    
                    Text(event.getStartHourAndMinute())
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
                        Text(String(localized: "status-live", table: "Events"))
                            .bold()
                            .font(.callout)
                    }.foregroundStyle(.red)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            case .ended:
                VStack (alignment: .trailing){
                    HStack {
                        Text(String(localized: "status-ended", table: "Events"))
                            .bold()
                            .font(.callout)
                    }.foregroundStyle(.gray)
                    
                    Text(event.getStopHourAndMinute())
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
        .padding(.horizontal, 10)
}
