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



/// Map view to see fields
struct MapView: View {
    
    @StateObject var router: EventRouter = EventRouter()
    
    @State private var showError: Bool = false
    @State private var showBottomSheet: Bool = true
    @State private var showFieldDetail: Bool = false
    @State private var showNewEvent: Bool = false
    @State private var showOptions: Bool = false
    @State private var selectedVenue: Venue?
    @State private var selectedEvent: Event?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @Environment(SessionStore.self) private var session
    
    var visibleRegion: MKCoordinateRegion?
    
    var sports: [String] {
        guard let user = session.user,
              let sports = user.sports else {
            return [String]()
        }
        return sports
    }
    
    // This fallback location is a second location in case we are unable to find the user's current location
    // In this case we check to see if they have a stored location(hometown)
    // If not then we default to apple park
    var fallbackLocation: MKCoordinateRegion {
        guard let user = session.user, let hometown = user.hometown else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988), latitudinalMeters: 5000, longitudinalMeters: 5000)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]), latitudinalMeters: 5000, longitudinalMeters: 5000)
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
            DraggableCard(detents: [.height(50), .height(250), .fraction(0.5)]) {
                EventsModalView(events: session.events)
            }
        }
        .ignoresSafeArea(edges: .all)
        .toolbar(.hidden, for: .navigationBar)
        .mapStyle(.standard(elevation: .realistic))
        .sheet(item: $selectedVenue) { field in
            VenueView(venue: field)
                .presentationDetents([.height(250), .large])
        }
        .fullScreenCover(isPresented: $showNewEvent, onDismiss: {
            //TODO: - fetch events
        }) {
            NewEvent(manager: NewEventManager())
        }
        .alert(isPresented: $showError){
            Alert(title: Text("Permission Denied"), message: Text("To use Olympsis's map features you need to allow us to use your location when in use of the app for accurate information."), dismissButton: .default(Text("Goto Settings"), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        }
        .task {
            cameraPosition = .userLocation(fallback: .region(fallbackLocation))
        }
    }
}

#Preview {
    MapView()
        .environment(SessionStore())
}
