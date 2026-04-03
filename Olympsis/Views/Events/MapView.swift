//
//  MapView.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import MapKit
import SwiftUI
import CoreLocation
import CoreLocationUI

struct MapView: View {
    
    @Binding var showNewEvent: Bool
    @Binding var selectedVenue: Venue?
    
    @State private var showError: Bool = false
    @State private var showOptions: Bool = false
    @State private var showNearbyEvents: Bool = false
    
    @State private var selectedEvent: Event?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @Environment(SessionStore.self) private var session
    @Environment(SearchManager.self) private var manager
    
    var visibleRegion: MKCoordinateRegion?
    
    private var sports: [String] {
        guard let user = session.user,
              let sports = user.sports else {
            return [String]()
        }
        return sports
    }
    
    private var events: [Event] {
        return session.events
            .filter { $0.tags.contains(manager.selectedTags) }
            .filter { $0.sports.contains(manager.selectedSports) }
    }
    
    // This fallback location is a second location in case we are unable to find the user's current location
    // In this case we check to see if they have a stored location(hometown)
    // If not then we default to apple park
    private var fallbackLocation: MKCoordinateRegion {
        guard let user = session.user, let hometown = user.hometown else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988), latitudinalMeters: 5000, longitudinalMeters: 5000)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hometown.coordinates[1], longitude: hometown.coordinates[0]), latitudinalMeters: 5000, longitudinalMeters: 5000)
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(session.venues) { venue in
                    Annotation(venue.name, coordinate: CLLocationCoordinate2D(latitude: venue.location.coordinates[1], longitude: venue.location.coordinates[0]), anchor: .bottom) {
                        VenueAnnotation(venue: venue)
                            .environment(session)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    selectedVenue = venue
                                    cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: venue.location.coordinates[1], longitude: venue.location.coordinates[0]), latitudinalMeters: 500, longitudinalMeters: 500))
                                }
                            }
                    }
                }
                UserAnnotation()
            }
            
            DraggableCard(detents: [.height(50), .fraction(0.45), .fraction(0.75)]) {
                EventsModalView(showNewEvent: $showNewEvent, showMoreEvents: $showNearbyEvents)
            }
        }
        .ignoresSafeArea(edges: .all)
        .mapStyle(.standard(elevation: .realistic))
        .alert(isPresented: $showError){
            Alert(title: Text(String(localized: "event-permission-denied-title", table: "Events")), message: Text(String(localized: "event-permission-denied-message", table: "Events")), dismissButton: .default(Text(String(localized: "event-goto-settings", table: "Events")), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        }
        .fullScreenCover(isPresented: $showNearbyEvents) {
            EventsList(events: events)
        }
        .task {
            cameraPosition = .userLocation(fallback: .region(fallbackLocation))
        }
    }
}

#Preview {
    MapView(showNewEvent: .constant(false), selectedVenue: .constant(nil))
        .environment(SessionStore())
        .environment(SearchManager())
}
