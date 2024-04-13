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
    
    @State private var showError: Bool = false
    @State private var showBottomSheet: Bool = true
    @State private var showFieldDetail: Bool = false
    @State private var showNewEvent: Bool = false
    @State private var showOptions: Bool = false
    
    @State private var selectedField: Field?
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
        Map(position: $cameraPosition) {
            ForEach(session.fields) { field in
                Annotation(field.name, coordinate: CLLocationCoordinate2D(latitude: field.location.coordinates[1], longitude: field.location.coordinates[0]), anchor: .bottom) {
                    PlaceAnnotationView(field: field)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedField = field
                                cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: field.location.coordinates[1], longitude: field.location.coordinates[0]), latitudinalMeters: 500, longitudinalMeters: 500))
                            }
                        }
                }
            }
            
            UserAnnotation()
            
        }.ignoresSafeArea(edges: .all)
            .mapStyle(.standard(elevation: .realistic))
            .overlay(alignment: .topTrailing) {
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Map")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        LocationButton(.currentLocation){
                            withAnimation {
                                cameraPosition = .automatic
                            }
                        }
                        .clipShape(Circle())
                        .labelStyle(.iconOnly)
                        .symbolVariant(.fill)
                        .foregroundColor(.white)
                        .tint(Color("color-secnd"))
                        .frame(width: 40, height: 40)
                        
                        Button(action:{ self.showOptions.toggle() }){
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
                        Button(action:{ self.showNewEvent.toggle() }){
                            ZStack {
                                Circle()
                                    .tint(Color("color-secnd"))
                                Image(systemName: "plus")
                                    .imageScale(.large)
                                    .symbolRenderingMode(.palette)
                                    .foregroundColor(.white)
                            }
                        }.frame(width: 41)
                        
                        Button(action:{ self.showBottomSheet.toggle() }){
                            ZStack {
                                Circle()
                                    .tint(Color("color-secnd"))
                                Image(systemName: "line.3.horizontal.decrease")
                                    .imageScale(.large)
                                    .symbolRenderingMode(.palette)
                                    .foregroundColor(.white)
                            }
                        }.frame(width: 41)
                            .padding(.top, 2)
                    }.padding(.horizontal)
                        .padding(.top, -12)
                }
            }.sheet(item: $selectedField) { field in
                FieldView(field: field)
                    .presentationDetents([.height(250), .large])
            }
            .fullScreenCover(isPresented: $showNewEvent) {
                NewEvent(manager: NewEventManager())
            }
            .sheet(isPresented: $showBottomSheet) {
                EventsModalView(events: $session.events)
                    .presentationDetents([.height(250), .large])
            }
            .sheet(isPresented: $showOptions) {
                MapOptions(availableSports: SPORT.allCases, selectedSports: sports)
                    .presentationDetents([.medium])
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView().environmentObject(SessionStore())
    }
}
