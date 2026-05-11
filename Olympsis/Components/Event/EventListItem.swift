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

    /// Pill showing the participant count. Pulled into its own
    /// `@ViewBuilder` so both the regular layout (title + location
    /// stacked on the left, capsule on the right) and the small
    /// layout (title spanning the card, location + capsule sharing
    /// a row below) can render the exact same chip without
    /// duplicating its styling.
    ///
    /// The downward offset that the regular layout uses to dangle
    /// this chip below the title/location pair is applied at the
    /// call site — in the small layout the chip sits inline with the
    /// location text, so the same offset would push it into the
    /// date row underneath.
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
                        Spacer()

                        if scale == .small {
                            // Small layout: title gets the full card
                            // width on its own row, then location and
                            // participants share the row below. Lets
                            // long titles breathe in the narrower
                            // small-card variant rather than being
                            // truncated to half the width by the
                            // participants chip sitting next to them.
                            Text(event.title)
                                .font(titleFont)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack {
                                Text("\(String(localized: "event-at-location", table: "Events")) \(venueLocationName)")
                                    .font(locationFont)
                                    .opacity(0.8)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .redacted(reason: canShowLocation ? [] : .placeholder)
                                
                                Spacer()
                                
                                participantsCapsule
                            }
                        } else {
                            HStack {

                                // MARK: - Title and Location
                                VStack(alignment: .leading) {
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

                                // MARK: - Participants
                                participantsCapsule
                                    // Regular layout dangles the
                                    // chip below the title/location
                                    // VStack — the small layout
                                    // doesn't because the chip lives
                                    // inline with the location text.
                                    .offset(x: 2, y: 8)
                            }
                        }

                        HStack(alignment: .center, spacing: 5) {

                            // MARK: - Date
                            HStack {
                                Image(systemName: "calendar")
                                    .imageScale(.small)
                                    .foregroundStyle(.white)
                                Text(event.timeToString())
                                    .font(dateFont)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }

                            Spacer()

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
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.95)
                            .mask(gradient)
                    }
                }.clipShape(RoundedRectangle(cornerRadius: 10))
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
