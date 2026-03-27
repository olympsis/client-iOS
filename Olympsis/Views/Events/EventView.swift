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
    
    @State private var venues = [Venue]()
    @State private var venuesTarget: Int = 0
    
    @State private var clubs = [Club]()
    @State private var organizations = [Organization]()
    
    @State private var showToast: Bool = false
    @State private var showSharingMenu: Bool = false
    
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
                    
                    // MARK: - Event Quick Info
                    EventQuickInfo(
                        event: event,
                        venues: $venues,
                        venuesTarget: $venuesTarget,
                        venuesState: $venueState
                    )
                    .padding(.top, isFullScreen ? 50 : 0)
                    .padding(.bottom, 10)
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
                        Text(event.body)
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
                    EventComments(clubs: $clubs, organizations: $organizations)
                        .environment(event)
                        .padding(.top)
                        .id(8)
                    
                    Spacer(minLength: 50)
                }
                .onChange(of: venuesTarget) { _, newValue in
                    proxy.scrollTo(newValue, anchor: .top)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(.regularMaterial)
        .background {
            KFImage(generateImageURL(event.mediaURL))
                .resizable()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 100, height: 100)))
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        }
        .toolbarTitleDisplayMode(.inline)
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
    NavigationStack {
        EventView(event: EVENTS[1], isFullScreen: true)
            .environment(EVENTS[1])
            .environment(SessionStore())
    }
}
