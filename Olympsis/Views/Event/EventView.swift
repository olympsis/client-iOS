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
    @State private var venues = [Venue]()
    @State private var clubs = [Club]()
    @State private var organizations = [Organization]()
    @State private var venuesTarget: Int = 0
    @State private var showFullImage: Bool = false
    @State private var showSharingMenu: Bool = false
    @State private var state: LOADING_STATE = .pending
    @State private var venueState: LOADING_STATE = .pending
    @State private var organizersState: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_view")
    
    private var eventTitle: String {
        guard let title = event.title else {
            return "Error"
        }
        return title
    }
    
    private var eventImage: URL? {
        guard let img = event.imageURL else {
            return nil
        }
        return generateImageURL(img)
    }
    
    private var eventBody: String {
        guard let body = event.body else {
            return ""
        }
        return body
    }
    
    private var organizers: [Organizer] {
        guard let organizers = event.organizers else {
            return [Organizer]()
        }
        return organizers
    }
    
    private var venueDescriptors: [VenueDescriptor] {
        guard let venues = event.venues else {
            return [VenueDescriptor]()
        }
        return venues
    }
    
    init(event: Event) {
        self._event = StateObject(wrappedValue: event)
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
                
                Button(action: { self.showSharingMenu = true }) {
                    Image(systemName: "square.and.arrow.up")
                }.clipShape(Rectangle())
                
                Button(action:{ dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                }.clipShape(Circle())

            }.padding([.top, .horizontal])
            
            ScrollView(showsIndicators: false) {
                ScrollViewReader { proxy in
                    VStack(alignment: .leading) {
                        
                        if event.type == "tournament" {
                            Text("Tournament")
                                .font(.caption)
                                .padding(.leading)
                                .bold()
                                .foregroundStyle(Color("color-tert"))
                        }
                        
                        // MARK: - Organizers Names
                        EventOrganizersView(event: event, clubs: $clubs, organizations: $organizations)
                            .padding(.horizontal)
                            .padding(.bottom, 3)
                            .redacted(reason: organizersState != .success ? .placeholder : [])
                            .zIndex(1)
                            .id(0)
                        
                        // MARK: - Field Info
                        VenueInfo(venues: $venues, venuesTarget: $venuesTarget, state: $venueState)
                            .zIndex(1)
                            .id(1)
                        
                        // MARK: - Event Image
                        if let url = eventImage {
                            KFImage(url)
                                .placeholder {
                                    Rectangle()
                                        .frame(height: 300)
                                        .foregroundStyle(.gray)
                                        .overlay {
                                            Image(systemName: "photo")
                                                .foregroundStyle(Color("foreground"))
                                        }
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .clipped()
                                .onTapGesture {
                                    self.showFullImage.toggle()
                                }
                                .zIndex(0)
                                .id(2)
                        } else {
                            Rectangle()
                                .frame(height: 300)
                                .foregroundStyle(.gray)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundStyle(Color("foreground"))
                                }
                        }
                        
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
                        }
                        .padding(.all)
                        .id(3)
                        
                        // MARK: - Middle View
                        EventMiddleView()
                            .id(4)
                            .environmentObject(event)
                        
                        // MARK: - Action Buttons
                        EventActionButtons(
                            venues: $venues, 
                            venueState: $venueState,
                            clubs: $clubs,
                            organizations: $organizations
                        )
                            .id(5)
                            .environmentObject(event)
                        
                        // MARK: - Participants View
                        EventParticipantsView()
                            .id(6)
                            .environmentObject(event)
                        
                        if !venues.isEmpty {
                            Group {
                                HStack {
                                    Text("Venue(s)")
                                        .font(.title2)
                                        .bold()
                                }
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center) {
                                    ForEach(venueDescriptors, id: \.self) {
                                        VenueDescriptorView(item: $0)
                                    }
                                }
                            }
                            .id(7)
                            .padding(.horizontal)
                        }
                    }
                    .onChange(of: venuesTarget) { _, newValue in
                        proxy.scrollTo(newValue, anchor: .top)
                    }
                    .fullScreenCover(isPresented: $showFullImage, content: {
                        if let img = eventImage {
                            FullImageViewer(imageURL: img)
                        }
                    })
                }
            }
        }
        .sheet(isPresented: $showSharingMenu, content: {
            ShareMenu(event: event, venue: venues[0])
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
        .environmentObject(SessionStore())
}
