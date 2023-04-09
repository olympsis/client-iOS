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
                Text(field.notes)
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
        let field = Field(id: "", owner: "", name: "Richard Building Fields", notes: "Just right across the way from the Orem Fitness Center and Mountain View High School, Community Park is a very large park with lots to offer residents. It has 5 baseball fields, 9 tennis courts, and plenty of open space for soccer, football, and outdoor games.", sports: [""], images: [""], location: GeoJSON(type: "", coordinates: [-111.656757, 40.247278]), city: "Provo", state: "Utah", country: "United States of America", ownership: "private")
        EventDetailFieldView(field: field)
    }
}
