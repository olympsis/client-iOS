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
import AlertToast
import CoreLocation

/// A view that shows more detail about a specific event
struct EventView: View {
    
    @StateObject var event: Event
    @State private var venues = [Venue]()
    @State private var clubs = [Club]()
    @State private var organizations = [Organization]()
    @State private var venuesTarget: Int = 0
    
    @State private var showToast: Bool = false
    @State private var showSharingMenu: Bool = false
    
    @State private var state: LOADING_STATE = .pending
    @State private var venueState: LOADING_STATE = .pending
    @State private var organizersState: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_view")
    
    private var eventTitle: String {
        return event.title
    }
    
    private var eventImage: URL? {
        return generateImageURL(event.mediaURL)
    }
    
    private var eventBody: String {
        return event.body
    }
    
    private var organizers: [Organizer] {
        return event.organizers
    }
    
    private var venueDescriptors: [VenueDescriptor] {
        return event.venues
    }
    
    init(event: Event) {
        self._event = StateObject(wrappedValue: event)
    }
    
    /// Update event data
    func reloadEvent() async {
        guard let resp = await session.eventObserver.fetchEvent(id: event.id) else {
            handleFailure()
            return
        }
        event.update(from: resp)
        
        handleSuccess()
    }
    
    /// Handles success
    func handleSuccess() {
        state = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    /// Handles faliures gracefully
    func handleFailure() {
        state = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    var body: some View {
        VStack {
            
            // MARK: - Event Top Bar
            HStack(alignment: .center) {
                Text(eventTitle)
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Spacer()
                
                Button(action: { self.showSharingMenu = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.large)
                }
                .padding(.horizontal, 10)
                .clipShape(Rectangle())
                .tint(Color.foreground)
                
                Button(action:{ dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.top, 5)
                        .imageScale(.large)
                }
                .clipShape(Circle())
                .tint(Color.foreground)

            }.padding([.top, .horizontal])
            
            
            ScrollView(showsIndicators: false) {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading) {
                        
                        // MARK: - Event Quick Info
                        EventQuickInfo(
                            event: event,
                            venues: $venues,
                            venuesTarget: $venuesTarget,
                            venuesState: $venueState
                        )
                        .padding(.bottom, 10)
                        .id(1)
                        
                        // MARK: - Event Media
                        EventMedia(event: event)
                            .id(2)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        // MARK: - Detail/Body
                        VStack(alignment: .leading) {
                            HStack {
                                Text(String(localized: "event-details-title", table: "Events"))
                                    .font(.title2)
                                    .bold()
                                
                               Spacer()
                            }
                            Text(eventBody)
                        }
                        .padding(.top, 10)
                        .padding([.horizontal, .bottom])
                        .id(3)
                        
                        // MARK: - Action Buttons
                        EventActionButtons(
                            venues: $venues, 
                            venueState: $venueState,
                            clubs: $clubs,
                            organizations: $organizations
                        )
                        .id(4)
                        .environmentObject(event)
                        
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
                            .environmentObject(event)
                            .id(6)
                        
                        // MARK: - Competiton formats
                        if let formats = event.formatConfig?.formats, !formats.isEmpty {
                            EventFormatView(event: event)
                        }
                        
                        // MARK: - Locations
                        EventLocation(venues: $venues)
                            .redacted(reason: venueState != .success ? .placeholder : [])
                            .environmentObject(event)
                            .id(7)
                        
                        // MARK: - Comments
                        EventComments(clubs: $clubs, organizations: $organizations)
                            .id(8)
                            .padding(.top)
                            .environmentObject(event)
                        
                        Spacer(minLength: 50)
                    }
                    .onChange(of: venuesTarget) { _, newValue in
                        proxy.scrollTo(newValue, anchor: .top)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .toast(isPresenting: $showToast, alert: {
            AlertToast(displayMode: .hud, type: .regular, title: "Event Link Copied")
        })
        .background(.regularMaterial)
        .background {
            KFImage(generateImageURL(event.mediaURL))
                .resizable()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 100, height: 100)))
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showSharingMenu, content: {
            ShareMenu(event: event, venue: venues[0], showToast: $showToast)
                .presentationDetents([.height(170)])
        })
        .task {
            // TODO: - I will want to make a synchronous call here
            venueState = .loading
            organizersState = .loading
            venues = await session.fetchVenues(in: venueDescriptors)
            (clubs, organizations) = await session.fetchOrganizers(in: organizers)
            venueState = .success
            organizersState = .success
        }
    }
}

#Preview {
    EventView(event: EVENTS[0])
        .environment(SessionStore())
}
