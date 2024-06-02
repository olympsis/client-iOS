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
    
    @StateObject var event: Event
    @State private var venue = Venue(
        id: UUID().uuidString,
        name: "Placeholder",
        owner: Ownership(name: "Placeholder", type: "placeholder"),
        description: "Placeholder text about this great venue",
        sports: [""],
        images: ["", "", ""],
        location: GeoJSON(type: "", coordinates: [Double]()),
        city: "Placeholder",
        state: "PH",
        country: "PlaceHolder"
    )
    @State private var showFullImage: Bool = false
    @State private var state: LOADING_STATE = .pending
    @State private var venueState: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_view")
    
    init(event: Event) {
        self._event = StateObject(wrappedValue: event)
    }
    
    var eventTitle: String {
        guard let title = event.title else {
            return "Error"
        }
        return title
    }
    
    var eventImage: String {
        guard let img = event.imageURL else {
            return ""
        }
        return  img
    }
    
    var eventBody: String {
        guard let body = event.body else {
            return ""
        }
        return body
    }
    
    /// Update event data
    func reloadEvent() async {
        guard let id = event.id,
              let resp = await session.eventObserver.fetchEvent(id: id) else {
            handleFailure()
            return
        }
        event.update(resp)
        
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
    
    /// We want to dynamically fetch the venue information to reduce the amount of data we're holding in memory
    ///
    /// We try to fetch the venue locally in memory if we have it stored and if it's an Olympsis vetted location.
    /// If we do not have the venue in memory we will try to fetch it remotely.
    /// If that fails then we will have to display an error.
    ///
    /// If the venue is not Olympsis vetted we will simply just open maps at the provided coordinates
    func fetchVenue() async {
        venueState = .loading
        guard var venue = event.venue else {
            log.error("Failed to verify external venue")
            return
        }
        if (venue.isInternal()) {
            guard let resp = await fetchVenueLocal() else {
                guard let resp = await fetchVenueRemote() else {
                    venueState = .failure
                    return
                }
                self.venue = resp
                venueState = .success
                return
            }
            self.venue = resp
            venueState = .success
        } else {
            guard let name = venue.name,
                  let location = venue.location else {
                log.error("Failed to verify external venue")
                return
            }
            venue.name = name
            venue.location = location
            venueState = .success
        }
        return
    }
    
    /// Fetch the venue from the data we have in memory
    /// - Returns: a `Venue` optional object in case we failt to find venue
    func fetchVenueLocal() async -> Venue? {
        guard let venue = event.venue,
              let venue = session.venues.first(where: { $0.id == "\(venue.id ?? "")" }) else {
            log.error("Failed to verify venue data or venue is not stored locally")
            return nil
        }
        return venue
    }
    
    /// Fetch the venue from the server
    /// - Returns: a `Venue` optinal object in case the server fails to find venue
    func fetchVenueRemote() async -> Venue? {
        guard let venue = event.venue,
              let venue = await session.fieldObserver.fetchVenue(id: "\(venue.id ?? "")") else {
            log.error("Failed to verify venue data to fetch remotely")
            return nil
        }
        session.venues.append(venue)
        return venue
    }
    
    /// Opens maps for the given coordinates
    /// - Parameter coordinates: `[Double]` of positional meters
    /// - Parameter venueName: `String` of venue name
    func openMapsForCoordinates(coordinates: [Double], venueName: String) {
        guard coordinates.count == 2 else {
            log.error("Error: Coordinates array must contain exactly 2 elements (latitude and longitude)")
            return
        }
        
        let latitude = coordinates[0]
        let longitude = coordinates[1]
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = venueName
        
        let regionDistance: CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        mapItem.openInMaps(launchOptions: options)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(eventTitle)
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Spacer()
                
                Button(action: { Task { await reloadEvent() }}) {
                    switch state {
                    case .pending:
                        withAnimation {
                            Image(systemName: "arrow.clockwise")
                                .fontWeight(.bold)
                        }
                    case .loading:
                        withAnimation {
                            ProgressView()
                        }
                    case .success:
                        withAnimation {
                            Image(systemName: "arrow.clockwise")
                                .fontWeight(.bold)
                        }
                    case .failure:
                        withAnimation {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .imageScale(.medium)
                        }
                    }
                }
                .clipShape(Circle())
                .frame(width: 25, height: 20)
                
                Button(action:{ dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                }
                .clipShape(Circle())
                .frame(width: 25, height: 20)

            }.padding([.top, .horizontal])
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    
                    if event.type == "tournament" {
                        Text("Tournament")
                            .font(.caption)
                            .padding(.leading)
                            .bold()
                            .foregroundStyle(Color("color-tert"))
                    }
                    
                    // MARK: - Organizers Names
                    EventOrganizersView(event: event)
                        .padding(.horizontal)
                        .padding(.bottom, 3)
                        .zIndex(1)
                    
                    // MARK: - Field Info
                    VenueInfo(state: $venueState, venue: $venue)
                        .zIndex(1)
                        
                    // MARK: - Event Image
                    Image(eventImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                        .zIndex(0)
                    
                    
                    // MARK: - Detail/Body
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Details")
                                .font(.title2)
                                .bold()
                            Rectangle()
                                .frame(height: 1)
                            Text(event.timeToString())
                                .font(.callout)
                        }
                        Text(eventBody)
                    }.padding(.all)
                    
                    // MARK: - Middle View
                    EventMiddleView()
                        .environmentObject(event)
                    
                    // MARK: - Action Buttons
                    EventActionButtons(venue: $venue, venueState: $venueState)
                        .environmentObject(event)
                    
                    // MARK: - Participants View
                    EventParticipantsView()
                        .environmentObject(event)
                }
            }
        }.task {
            await fetchVenue()
        }
    }
}

#Preview {
    EventView(event: EVENTS[0])
        .environmentObject(SessionStore())
}
