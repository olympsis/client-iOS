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

///
struct MapView: View {
    
    @State private var showError: Bool = false
    @State private var showBottomSheet: Bool = true
    @State private var showFieldDetail: Bool = false
    @State private var showNewEvent: Bool = false
    @State private var showOptions: Bool = false
    
    @State private var selectedField: Field?
    
    @State var trackingMode: MapUserTrackingMode = .follow
    @State var region : MKCoordinateRegion = .init()
    @EnvironmentObject var session:SessionStore

    var sports: [String] {
        guard let user = session.user,
              let sports = user.sports else {
            return [String]()
        }
        return sports
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .topTrailing){
                    Map(coordinateRegion: $session.locationManager.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $trackingMode, annotationItems: session.fields, annotationContent: { field in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: field.location.coordinates[1], longitude: field.location.coordinates[0]), anchorPoint: CGPoint(x: 0.5, y: 0.5)) {
                            PlaceAnnotationView(field: field)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        selectedField = field
                                        session.locationManager.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: field.location.coordinates[1], longitude: field.location.coordinates[0]), latitudinalMeters: 500, longitudinalMeters: 500)
                                    }
                                }
                        }
                    }) .edgesIgnoringSafeArea(.all)
                    
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
                        }.padding(.vertical, 10)
                        .frame(width: 41)
                        
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
                    }.padding(.horizontal)
                    
                }
            }.toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Map")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    LocationButton(.currentLocation){
                        session.locationManager.manager.requestWhenInUseAuthorization()
                        withAnimation{
                            trackingMode = .follow;
                        }
                    }
                    .clipShape(Circle())
                    .labelStyle(.iconOnly)
                    .symbolVariant(.fill)
                    .foregroundColor(.white)
                    .tint(Color("color-secnd"))
                    .frame(width: 40, height: 40)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
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
                }
            }
            .sheet(item: $selectedField) { field in
                FieldViewExt(field: field)
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
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView().environmentObject(SessionStore())
    }
}
