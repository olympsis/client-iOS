//
//  EventDetailMapView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI
import MapKit

struct EventDetailFieldView: View {
    @State var field: Field
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(field.name)
                    .font(.title)
                    .bold()
                Text(field.description)
            }.frame(width: SCREEN_WIDTH-20)
            VStack {
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: field.location.coordinates[1], longitude: field.location.coordinates[0]), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))), interactionModes: .pan, showsUserLocation: false, annotationItems: [field], annotationContent: { field in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: field.location.coordinates[1], longitude: field.location.coordinates[0]), tint: Color("primary-color"))
                }).frame(width: SCREEN_WIDTH-20, height: 270)
                    .cornerRadius(10)
            }.frame(width: SCREEN_WIDTH-20)
        }
    }
}

struct EventDetailFieldView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailFieldView(field: FIELDS[0])
    }
}
