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

    // `Event` is already a reference type, so `@State` adds a per-row
    // storage allocation that buys nothing. A plain `let` is enough —
    // mutations to event properties propagate via `@Observable`.
    let event: Event
    var scale: LIST_ITEM_SCALE = .regular
    var namespace: Namespace.ID? = nil
    /// Optional tap override. When provided we drop the implicit
    /// `NavigationLink` and let the caller drive navigation through a
    /// router — needed when the list lives inside a sheet (e.g. mobile
    /// `ExplorerList`), since `NavigationLink` can't push onto the
    /// underlying `NavigationStack` from a separate presentation.
    var onTap: (() -> Void)? = nil

    @State private var status: LOADING_STATE = .loading
    
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
        scale == .regular ? 100 : 78
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
                // Decode the image at a list-card resolution rather than
                // its native size — saves both the decode CPU and the
                // memory cost of holding 4K-ish JPEGs for cards that
                // top out around 1000pt wide.
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 1000, height: 600)))
                .scaledToFill()
                .clipped()
                .zIndex(1)
                .frame(height: imageHeight)
                .overlay(alignment: .bottom) {
                    VStack(spacing: 5) {
                        Spacer()
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
                            .offset(x: 2, y: 8)
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
                // Caller is handling navigation (typically via a router
                // because we're inside a sheet that doesn't share the
                // parent's `NavigationStack`).
                Button(action: onTap) {
                    cardContent
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
