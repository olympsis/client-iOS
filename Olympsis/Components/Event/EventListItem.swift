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

    let event: Event
    var scale: LIST_ITEM_SCALE = .regular
    var namespace: Namespace.ID? = nil
    var onTap: (() -> Void)? = nil

    @State private var showDetails = false
    @State private var status: LOADING_STATE = .loading
    
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
    
    private let log: Logger = Logger(
        subsystem: "com.olympsis.client",
        category: "event_list_item"
    )
    
    private var type: String {
        guard let isTournament = event.formatConfig?.isCompetition else {
            return "PICKUP"
        }
        return isTournament ? "TOURNAMENT" : "PICK UP"
    }
    
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
    
    /// Compute event image url
    private var imageURL: URL? {
        return generateImageURL(event.mediaURL)
    }
    
    /// Compute the event's location name
    private var venueLocationName: String {
        guard let first = event.venues.first else {
            return "Custom Location"
        }
        // Prefer the name embedded on the descriptor — most events ship
        // with one and we never need to round-trip the cache.
        if let name = first.name { return name }
        // Otherwise fall back to the cached venue (hydrated in bulk by
        // `EventsViewModel.loadEvents`).
        if let id = first.id,
           let venue = session.venues.first(where: { $0.id == id }) {
            return venue.name
        }
        return "Custom Location"
    }
    
    /// Compute the event sports type
    private var eventSport: String {
        guard let sport = event.sports.first else {
            return "Activity"
        }
        return sport.prefix(1).capitalized + sport.dropFirst()
    }
    

    // MARK: - Scale-derived sizing
    //
    // Centralizes every scale-sensitive value in one place so the body
    // doesn't sprout a `scale == .regular ? ... : ...` ternary at every
    // call site. `.small` is used inside the iPad split-view explorer
    // where the list takes up roughly a third of the screen and needs
    // every element to compress proportionally.

    private var imageHeight: CGFloat {
        scale == .regular ? 250 : 180
    }

    /// Height of the bottom info overlay. Trimmed in `.small` so two lines
    /// of meta still fit without truncating titles.
    private var overlayHeight: CGFloat {
        scale == .regular ? 100 : 85
    }

    private var titleFont: Font {
        scale == .regular ? .title3 : .headline
    }

    private var locationFont: Font {
        scale == .regular ? .body : .subheadline
    }

    private var dateFont: Font {
        scale == .regular ? .callout : .footnote
    }

    /// Used by the participant / sport / time / tournament capsules.
    private var tagFont: Font {
        scale == .regular ? .caption : .caption2
    }

    /// Inner padding on the capsule tags — we drop 2 pts in `.small` so
    /// the row of capsules still fits the narrower layout.
    private var tagPadding: CGFloat {
        scale == .regular ? 5 : 3
    }

    private var overlayHorizontalPadding: CGFloat {
        scale == .regular ? 7 : 6
    }

    private var overlayBottomPadding: CGFloat {
        scale == .regular ? 7 : 12
    }

    @ViewBuilder
    private var participantsCapsule: some View {
        HStack {
            Image(systemName: "person.2.fill")
                .imageScale(.small)
                .foregroundStyle(.white)

            Text("\(event.participants.count) \(String(localized: "event-participants", table: "Events"))")
                .font(tagFont)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.trailing, 2.5)
        }
        .padding(tagPadding)
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

    @ViewBuilder
    private var cardContent: some View {
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
                .cacheOriginalImage()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 1000, height: 600)))
                .scaledToFill()
                .clipped()
                .zIndex(1)
                .frame(height: imageHeight)
                .overlay(alignment: .bottom) {
                    VStack(spacing: 5) {

                        if scale == .small {
                            VStack(alignment: .leading) {
                                Text(type)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.Foreground.yellow)
                                
                                Text(event.title)
                                    .font(titleFont)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            HStack {
                                Text("\(String(localized: "event-at-location", table: "Events")) \(venueLocationName)")
                                    .font(locationFont)
                                    .opacity(0.8)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .redacted(reason: canShowLocation ? [] : .placeholder)
                                
                                Spacer()
                                
                                // Date
                                HStack {
                                    Image(systemName: "calendar")
                                        .imageScale(.small)
                                        .foregroundStyle(.white)
                                    Text(event.timeToString())
                                        .font(dateFont)
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                }
                            }
                        } else {
                            HStack(alignment: .bottom) {

                                // MARK: - Title and Location
                                VStack(alignment: .leading) {
                                    Text(type)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color.Foreground.yellow)
                                    
                                    Text(event.title)
                                        .font(titleFont)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .lineLimit(1)

                                    Text("\(String(localized: "event-at-location", table: "Events")) \(venueLocationName)")
                                        .font(locationFont)
                                        .opacity(0.8)
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .redacted(reason: canShowLocation ? [] : .placeholder)
                                }

                                Spacer()

                                // Date
                                HStack {
                                    Image(systemName: "calendar")
                                        .imageScale(.small)
                                        .foregroundStyle(.white)
                                    Text(event.timeToString())
                                        .font(dateFont)
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                }
                            }
                        }

                        HStack(alignment: .center, spacing: 5) {

                            // MARK: - Competition Tag
                            if event.isCompetition() {
                                HStack {
                                    Text(String(localized: "event-tournament", table: "Events"))
                                        .font(tagFont)
                                        .fontWeight(.bold)
                                        .padding([.leading, .trailing], 2.5)
                                        .foregroundStyle(Color.Brand.quaternary)
                                }
                                .padding(tagPadding)
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
                                    .font(tagFont)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding([.leading, .trailing], 2.5)
                            }
                            .padding(tagPadding)
                            .background(
                                Color.black
                                    .opacity(0.21)
                            )
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            }

                            Spacer()
                            
                            // MARK: - Start Time
                            HStack {
                                Image(systemName: "clock")
                                    .imageScale(.small)
                                    .foregroundStyle(.white)
                                Text(event.getStartHourAndMinute())
                                    .font(tagFont)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.trailing, 2.5)
                            }
                            .padding(tagPadding)
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
                    .padding([.leading, .trailing], overlayHorizontalPadding)
                    .padding(.bottom, overlayBottomPadding)
                    .frame(height: overlayHeight)
                    .background {
                        // Frosted base — fades in from the top so the upper
                        // part of the image stays clear.
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.95)
                            .mask(gradient)
                            .overlay {
                                // The frosted material is translucent, so over
                                // bright areas of the image (e.g. out-of-focus
                                // grass) it stops reading as a shadow near the
                                // bottom edge — making the shadow look like it
                                // ends short of the card. This dark gradient
                                // guarantees a continuous darkening all the way
                                // to the bottom regardless of the image content.
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.35)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    ParticipantsStack(participants: event.participants, maxVisible: 3)
                        .padding([.top, .trailing], 8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) {
                    cardContent
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink(destination: EventView(event: event, namespace: namespace).environment(event).environment(session)) {
                    cardContent
                }
            }
        }
        .modifier(ZoomTransitionSourceModifier(id: event.id, namespace: namespace))
    }
}

#Preview("Regular") {
    EventListItem(event: EVENTS[0])
        .environment(SessionStore())
        .padding(.horizontal, 10)
}

#Preview("Small") {
    EventListItem(event: EVENTS[0], scale: .small)
        .environment(SessionStore())
        .padding(.horizontal, 10)
}
