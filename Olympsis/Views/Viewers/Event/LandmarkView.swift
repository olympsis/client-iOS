//
//  LandmarkView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/12/23.
//

import MapKit
import SwiftUI

struct LandmarkView: View {
    
    @Binding var landmark: MKMapItem
    
    var name: String {
        guard let name = landmark.name else {
            return "error"
        }
        return name
    }
    
    var landmarkType: String {
        guard let type = landmark.pointOfInterestCategory else {
            return "unknown category"
        }
        return type.rawValue
    }
    
    var body: some View {
        
        // map coordinate binding
        let binding = Binding<MKCoordinateRegion>(
            get: {
                let center = CLLocationCoordinate2D(latitude: landmark.placemark.coordinate.latitude, longitude: landmark.placemark.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                return region
            },
            set: { _ in }
        )
        
        // annotation struct and variable
        struct Annotation: Identifiable {
            let id = UUID()
            let coordinate: CLLocationCoordinate2D
        }
        let annotation = Annotation(coordinate: CLLocationCoordinate2D(latitude: landmark.placemark.coordinate.latitude, longitude: landmark.placemark.coordinate.longitude))
        
        return HStack {
            VStack {
                Text(name)
                    .font(.title3)
            }.padding(.horizontal)
            Spacer()
            Map(coordinateRegion: binding, interactionModes: .pan, annotationItems: [annotation]) { land in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: land.coordinate.latitude, longitude: land.coordinate.longitude), tint: Color("primary-color"))
            }
            .frame(width: 100, height: 100)
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

struct LandmarkView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkView(landmark: .constant(LANDMARKS[0]))
    }
}
