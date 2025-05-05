//
//  VenueSmallListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/24.
//

import MapKit
import SwiftUI

struct VenueMediumListItem: View {
    
    var item: Venue
    
    private var name: String {
        return item.name
    }
    
    private var locationString: String {
        return "\(item.city), \(item.state)"
    }
    
    private var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: item.location.coordinates[1], longitude: item.location.coordinates[0])
    }
    
    @State private var camera: MapCameraPosition
    
    init(item: Venue) {
        self.item = item
        self.camera = MapCameraPosition.camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: item.location.coordinates[1], longitude: item.location.coordinates[0]), distance: 1000))
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.title2)
                    .lineLimit(1)
                Text(locationString)
                    .lineLimit(1)
                    .foregroundStyle(.gray)
                
                Map(position: $camera, interactionModes: .pan) {
                    Marker(name, coordinate: location)
                }
                .disabled(true)
                .frame(height: 100)
                .mapStyle(.standard(elevation: .realistic))
                .cornerRadius(radius: 10, corners: .allCorners)
            }
        }
    }
}

#Preview {
    VenueMediumListItem(item: VENUES[0])
}
