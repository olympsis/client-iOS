//
//  EventQuickInfo.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import os
import MapKit
import SwiftUI
import CoreLocation

struct EventQuickInfo: View {
    
    var event: Event
    @Binding var venues: [Venue]
    @Binding var venuesTarget: Int
    @Binding var venuesState: LOADING_STATE
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_quick_info_view")
    
    /// Opens maps for the given coordinates
    /// - Parameter coordinates: `[Double]` of positional meters
    /// - Parameter venueName: `String` of venue name
    private func openMapsForCoordinates(coordinates: [Double], venueName: String) {
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
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "calendar")
                    .imageScale(.large)
                
                VStack(alignment: .leading) {
                    Text(event.timeToString())
                        .fontWeight(.bold)
                    Text("\(event.getStartHourAndMinute()) - \(event.getStopHourAndMinute())")
                }
            }.padding(.bottom, 5)
            
            VenueInfo(venues: $venues, venuesTarget: $venuesTarget, state: $venuesState)
                .zIndex(1)
                .id(1)
        }.padding(.horizontal)
    }
}

#Preview {
    EventQuickInfo(event: EVENTS[0], venues: .constant([]), venuesTarget: .constant(0), venuesState: .constant(.success))
}
