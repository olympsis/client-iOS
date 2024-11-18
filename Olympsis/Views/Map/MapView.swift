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
    @State private var showBottomSheet: Bool = false
    @State private var showFieldDetail: Bool = false
    @State private var showNewEvent: Bool = false
    @State private var showOptions: Bool = false
    @State private var selectedVenue: Venue?
    @State private var selectedEvent: Event?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @EnvironmentObject private var session:SessionStore
    
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
        NavigationStack(path: $router.navPath) {
            Map(position: $cameraPosition) {
                ForEach(session.venues) { venue in
                    Annotation(venue.name, coordinate: CLLocationCoordinate2D(latitude: venue.location.coordinates[1], longitude: venue.location.coordinates[0]), anchor: .bottom) {
                        VenueAnnotation(venue: venue)
                            .environmentObject(session)
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
            .ignoresSafeArea(edges: .all)
            .toolbar(.hidden, for: .navigationBar)
            .mapStyle(.standard(elevation: .realistic))
            .overlay(alignment: .topTrailing) {
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Events")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        LocationButton(.currentLocation){
                            withAnimation {
                                cameraPosition = .userLocation(fallback: .region(fallbackLocation))
                            }
                        }
                        .clipShape(Circle())
                        .labelStyle(.iconOnly)
                        .symbolVariant(.fill)
                        .foregroundColor(.white)
                        .tint(Color("color-secnd"))
                        .frame(width: 40, height: 40)
                        
                        Button(action:{ self.router.navigate(to: .settings) }){
                            ZStack {
                                Circle()
                                    .tint(Color("color-secnd"))
                                    .frame(width: 41, height: 41)
                                Image(systemName: "slider.vertical.3")
                                    .imageScale(.large)
                                    .symbolRenderingMode(.palette)
                                    .foregroundColor(.white)
                            }
                        }.frame(width: 41, height: 41)
                    }.padding(.horizontal)
                    
                    VStack {
                        Button(action:{ self.showNewEvent = true }){
                            ZStack {
                                Circle()
                                    .tint(Color("color-secnd"))
                                Image(systemName: "plus")
                                    .imageScale(.large)
                                    .symbolRenderingMode(.palette)
                                    .foregroundColor(.white)
                            }
                        }.frame(width: 41)
                        
                        Button(action:{ self.showBottomSheet = true }){
                            Circle()
                                .tint(Color("color-secnd"))
                                .overlay {
                                    Image(systemName: "line.3.horizontal.decrease")
                                        .imageScale(.large)
                                        .symbolRenderingMode(.palette)
                                        .foregroundColor(.white)
                                        
                                }
                                .overlay(alignment: .topTrailing) {
                                    if session.events.count > 0 {
                                        Circle()
                                            .foregroundStyle(.red)
                                            .frame(width: 15, height: 15)
                                    }
                                }
                        }
                        .frame(width: 41)
                        .padding(.top, 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, -12)
                }.zIndex(10)
            }
            .navigationDestination(for: EVENT_ROUTES.self, destination: { route in
                switch route {
                case .events(let eventId, let openEvents):
                    if let eventId {
                        AsyncEventView(eventId: eventId)
                            .toolbar(.hidden, for: .navigationBar)
                    } else if openEvents != nil && openEvents == true {
                        EventsList(events: session.events)
                    }
                case .settings:
                    MapOptions(availableSports: SPORTS.allCases, selectedSports: sports)
                        .environmentObject(router)
                }
            })
        }
        .sheet(item: $selectedVenue) { field in
            VenueView(venue: field)
                .presentationDetents([.height(250), .large])
        }
        .fullScreenCover(isPresented: $showNewEvent) {
            NewEvent(manager: NewEventManager())
        }
        .sheet(isPresented: $showBottomSheet) {
            EventsModalView(events: $session.events)
                .presentationDetents([.height(250), .large])
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
    let session = SessionStore()
    return MapView()
        .environmentObject(session)
}
