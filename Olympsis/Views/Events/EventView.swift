//
//  EventViewExt.swift
//  Olympsis
//
//  Created by Joel on 7/27/23.
//

import os
import MapKit
import SwiftUI
import Kingfisher
import CoreLocation

/// A view that shows more detail about a specific event
struct EventView: View {
    
    var event: Event
    var isFullScreen: Bool = false
    var namespace: Namespace.ID? = nil
    /// Section to auto-scroll to when the view appears. Set when the
    /// event is opened from a tapped push notification (new participant
    /// or new comment). `nil` for normal navigation.
    var focus: EventFocus? = nil

    @State private var venues = [Venue]()
    @State private var venuesTarget: Int = 0
    /// Guards `scrollToFocus` so the notification jump only fires once.
    @State private var didApplyFocus: Bool = false

    @State private var clubs = [Club]()
    @State private var organizations = [Organization]()
    
    @State private var showToast: Bool = false
    @State private var showSharingMenu: Bool = false
    @State private var isComposing: Bool = false

    @State private var state: LOADING_STATE = .pending
    @State private var venueState: LOADING_STATE = .pending
    @State private var organizersState: LOADING_STATE = .pending
    
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_view")
    
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
    
    /// Every event in this event's recurring series, pulled from the
    /// session's hydrated events. Covers both backend-linked recurrences
    /// (shared `recurrenceConfig.parentEventID`) and scraped series
    /// (same title + same coordinates, different dates) — see
    /// `Array<Event>.recurringSeries(of:)`.
    private var seriesEvents: [Event] {
        Array(session.events).recurringSeries(of: event)
    }

    /// Compute wether or not this event is a recurring one
    /// We show the caption and the list of the recurring events.
    ///
    /// A backend-linked recurrence is "recurring" on its own (the config
    /// is authoritative even before siblings load). A *scraped* series only
    /// reads as recurring once we actually have more than one occurrence
    /// hydrated, otherwise a plain one-off event would falsely show the
    /// banner.
    private var isRecurringEvent: Bool {
        event.recurrenceConfig != nil || seriesEvents.count > 1
    }

    /// Future occurrences in this event's recurring series, sorted
    /// oldest → newest, *including the current event* when it's still
    /// upcoming. Including self keeps the existence check trivial — show
    /// the pill row when `count > 1`, since that guarantees at least one
    /// sibling to navigate to.
    ///
    /// Candidates come from `session.events` (whatever the explorer fetch
    /// has hydrated) re-stitched into a series by `recurringSeries(of:)`.
    private var upcomingRecurrences: [Event] {
        guard isRecurringEvent else { return [] }
        let now = Date()
        return seriesEvents
            .filter { $0.startTime > now }
            .sorted { $0.startTime < $1.startTime }
    }

    /// When the event is opened from a tapped push notification, jump to
    /// the relevant section. Runs once (guarded by `didApplyFocus`). The
    /// short delay lets the scroll view finish its initial layout —
    /// organizers/venues load asynchronously and shift content height, so
    /// scrolling immediately would land on the wrong offset.
    ///
    /// Section ids mirror the `.id(...)` tags applied below:
    /// `6` = participants. Comments are tagged with their own comment id
    /// inside `EventComments`, so we scroll straight to the comment.
    private func scrollToFocus(using proxy: ScrollViewProxy) {
        guard let focus, !didApplyFocus else { return }
        didApplyFocus = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut) {
                switch focus {
                case .participants:
                    proxy.scrollTo(6, anchor: .top)
                case .comment(let id):
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        }
    }

    /// Opens an external link URL in the browser.
    private func openExternalURL(_ link: EventLink) {
        let raw = link.url.contains("://") ? link.url : "https://" + link.url
        guard let url = URL(string: raw), UIApplication.shared.canOpenURL(url) else {
            return
        }
        openURL(url)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ScrollViewReader { proxy in
                VStack(alignment: .leading) {
                    
                    // Shows a recurring event caption and dates if possible
                    if isRecurringEvent {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .bottom, spacing: 5) {
                                Image(systemName: "arrow.clockwise")
                                    .imageScale(.small)
                                    .foregroundStyle(Color.Brand.tertiary)
                                
                                Text("This is a recurring event")
                                    .italic()
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }.padding(.leading)

                            if upcomingRecurrences.count > 1 {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(
                                            upcomingRecurrences.filter { $0.id != event.id },
                                            id: \.id
                                        ) { sibling in
                                            NavigationLink(value: EVENT_ROUTES.event(event: sibling)) {
                                                Text(sibling.timeToString())
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.Background.secondary)
                                                    .clipShape(Capsule())
                                                    .foregroundStyle(.primary)
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                                                    )
                                            }.buttonStyle(.plain)
                                        }
                                    }.padding(.horizontal)
                                }
                            }
                        }
                        .padding(.bottom, 10)
                        .padding(.top, isFullScreen ? 50 : 0)
                    }
                    
                    
                    
                    // MARK: - Event Quick Info
                    EventQuickInfo(
                        event: event,
                        venues: $venues,
                        venuesTarget: $venuesTarget,
                        venuesState: $venueState
                    )
                    .padding(.bottom, 10)
                    .padding(.top, (isFullScreen && !isRecurringEvent) ? 50 : 0)
                    .id(1)
                    
                    // MARK: - Event Media
                    EventMedia(event: event)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .id(2)
                    
                    // MARK: - Detail/Body
                    VStack(alignment: .leading) {
                        HStack {
                            Text(String(localized: "event-details-title", table: "Events"))
                                .font(.title2)
                                .bold()
                            
                            Spacer()
                        }
                        
                        ExpandableHTMLText(html: event.body)
                    }
                    .padding(.top, 10)
                    .padding([.horizontal, .bottom])
                    .id(3)
                    
                    if let links = event.externalLinks, !links.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(links) { link in
                                Button(action: { openExternalURL(link) }) {
                                    HStack {
                                        Image(systemName: "link")
                                            .imageScale(.large)
                                            .foregroundStyle(Color.Brand.tertiary)
                                        
                                        Text(link.title.isEmpty ? link.url : link.title)
                                            .font(.callout)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                        }
                        .padding([.horizontal, .bottom])
                    }
                    
                    // MARK: - Action Buttons
                    EventActionButtons(
                        venues: $venues,
                        venueState: $venueState,
                        clubs: $clubs,
                        organizations: $organizations
                    )
                    .environment(event)
                    .id(4)
                    
                    // MARK: - Organizers
                    EventOrganizers(event: event, clubs: $clubs, organizations: $organizations)
                        .padding(.horizontal)
                        .padding(.bottom, 3)
                        .padding(.top)
                        .redacted(reason: organizersState != .success ? .placeholder : [])
                        .zIndex(1)
                        .id(5)
                    
                    
                    // MARK: - Participants View
                    EventParticipants(clubs: $clubs, organizations: $organizations)
                        .environment(session)
                        .environment(event)
                        .id(6)
                    
                    // MARK: - Competiton formats
                    if let formats = event.formatConfig?.formats, !formats.isEmpty {
                        EventFormatView(event: event)
                    }
                    
                    // MARK: - Locations
                    if canShowLocation {
                        EventLocation(venues: $venues)
                            .redacted(reason: venueState != .success ? .placeholder : [])
                            .environment(event)
                            .id(7)
                    }
                    
                    // MARK: - Comments
                    // The compose field is no longer inline; tapping the
                    // header button flips `isComposing`, which surfaces
                    // the floating `EventCommentComposer` hosted as a
                    // bottom overlay below so it rides over the keyboard.
                    EventComments(
                        clubs: $clubs,
                        organizations: $organizations,
                        isComposing: $isComposing
                    )
                    .environment(event)
                    .padding(.top)
                    .id(8)
                    
                    Spacer(minLength: 160)
                }
                .onChange(of: venuesTarget) { _, newValue in
                    proxy.scrollTo(newValue, anchor: .top)
                }
                .onAppear {
                    scrollToFocus(using: proxy)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        // Floating comment composer. Hosted here (not inside the
        // scrolling content) and attached as a bottom overlay so that,
        // because this layer participates in keyboard safe-area
        // avoidance, SwiftUI lifts it above the keyboard — same trick
        // as the events-explorer search bar.
        .overlay(alignment: .bottom) {
            if isComposing {
                EventCommentComposer(isActive: $isComposing)
                    .environment(event)
                    .environment(session)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: isComposing)
        .background(.regularMaterial)
        .background {
            KFImage(generateImageURL(event.mediaURL))
                .resizable()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 100, height: 100)))
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        }
        .toolbarTitleDisplayMode(.inline)
        .modifier(ZoomTransitionModifier(id: event.id, namespace: namespace))
        .navigationTitle(Text(event.title))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { self.showSharingMenu = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.medium)
                }
            }
        }
        .sheet(isPresented: $showSharingMenu, content: {
            ShareMenu(event: event, venue: venues[0], showToast: $showToast)
                .presentationDetents([.height(170)])
        })
        .task {
            guard venueState == .pending,
                  organizersState == .pending else { return }
            
            venueState = .loading
            organizersState = .loading
            venues = await session.fetchVenues(in: event.venues)
            (clubs, organizations) = await session.fetchOrganizers(in: event.organizers)
            venueState = .success
            organizersState = .success
        }
        .overlay(alignment: .top) {
            if isFullScreen {
                HStack {
                    if #available(iOS 26.0, *) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .padding(.horizontal)
                                .padding(.vertical, 13)
                        }
                        .glassEffect()
                    } else {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Text(event.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if #available(iOS 26.0, *) {
                        Button(action: { self.showSharingMenu = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .imageScale(.medium)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                        }
                        .clipShape(Circle())
                        .glassEffect()
                    } else {
                        Button(action: { self.showSharingMenu = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .imageScale(.medium)
                        }
                    }
                }.padding(.horizontal)
            }
        }
    }
}

#Preview {
    EventView(event: EVENTS[0], isFullScreen: true)
        .environment(EVENTS[0])
        .environment(SessionStore())
}
