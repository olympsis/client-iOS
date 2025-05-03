//
//  EventQuickInfo.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import os
import MapKit
import SwiftUI
import EventKit
import CoreLocation

struct EventQuickInfo: View {
    
    var event: Event
    @Binding var venues: [Venue]
    @Binding var venuesTarget: Int
    @Binding var venuesState: LOADING_STATE
    @State private var showCalendarEditor: Bool = false
    
    private let store = EKEventStore()
    
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
    
    /// Creates a calendar event for the sports event
    /// - Returns:  an `EKEvent` object to pass to the `EventKitUI` view to create the calendar event
    private func createCalendarEvent() -> EKEvent {
        let _event = EKEvent(eventStore: store)
        _event.title = "Olympsis: \(event.title)"
        _event.startDate = event.startTime
        _event.endDate = event.stopTime
        _event.notes = event.body
        _event.url = URL(string: "https://olympsis.com/events/\(event.id)")
        _event.alarms = [EKAlarm(relativeOffset: -30 * 60)]
        _event.calendar = store.defaultCalendarForNewEvents
        
        // Add the event's first venue location
        if let location = venues.first?.location {
            _event.structuredLocation = EKStructuredLocation(mapItem: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.coordinates[1], longitude: location.coordinates[0]))))
        }
        
        return _event
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "calendar")
                    .imageScale(.large)
                
                VStack(alignment: .leading) {
                    Text(event.timeToString())
                        .fontWeight(.bold)
                    Text("\(event.getStartHourAndMinute()) - \(event.getStopHourAndMinute())")
                }
            }
            
            VenueInfo(venues: $venues, venuesTarget: $venuesTarget, state: $venuesState)
                .zIndex(1)
                .id(1)
            
            // Only show the add to calendar button if the event is pending
            if (event.getEventStatus() != .ended || event.getEventStatus() != .live) {
                Button(action: { self.showCalendarEditor.toggle() }) {
                    Text("Add to Calendar")
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .modifier(BackgroundPillModifier())
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showCalendarEditor) {
            CalendarEventEditView(eventStore: self.store, event: self.createCalendarEvent()) { _ in
                showCalendarEditor.toggle()
            }
        }
        
    }
}

#Preview {
    EventQuickInfo(event: EVENTS[0], venues: .constant([]), venuesTarget: .constant(0), venuesState: .constant(.success))
}
