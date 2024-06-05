//
//  EventVenuePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/24.
//

import os
import MapKit
import SwiftUI

struct EventVenuePicker: View {
    
    var venues: [Venue] {
        return session.venues
    }
    
    @State private var index: Int = 0
    @State private var search: String = ""
    @State private var customVenues = [Venue]()
    @State private var state: LOADING_STATE = .pending
    
    @StateObject private var searchModel = VenueSearchViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var manager: NewEventManager
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_venue_picker")
    
    func search(_ text: String) async {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = session.locationManager.region
        request.resultTypes = .pointOfInterest
        
        let searchRequest = MKLocalSearch(request: request)
        
        do {
            state = .loading
            let results = try await searchRequest.start()
            let points = results.mapItems
            if points.count > 100 {
                let reduced = points.dropLast(points.count - 100)
                reduced.forEach { item in
                    guard let name = item.name,
                          let state = item.placemark.administrativeArea,
                          let city = item.placemark.subAdministrativeArea,
                          let country = item.placemark.country else {
                        return
                    }
                    let location = item.placemark.coordinate
                    
                    self.customVenues.append(
                        Venue(
                            name: name,
                            location: GeoJSON(
                                type: "point",
                                coordinates: [
                                    Double(location.longitude),
                                    Double(location.latitude)
                                ]
                            ),
                            city: city,
                            state: state,
                            country: country
                        )
                    )
                }
            } else {
                points.forEach { item in
                    guard let name = item.name,
                          let state = item.placemark.administrativeArea,
                          let city = item.placemark.subAdministrativeArea,
                          let country = item.placemark.country else {
                        return
                    }
                    let location = item.placemark.coordinate
                    
                    self.customVenues.append(
                        Venue(
                            name: name,
                            location: GeoJSON(
                                type: "point",
                                coordinates: [
                                    Double(location.longitude),
                                    Double(location.latitude)
                                ]
                            ),
                            city: city,
                            state: state,
                            country: country
                        )
                    )
                }
            }
            state = .success
        } catch {
            log.error("Failed to search for venues: \(error.localizedDescription)")
            state = .failure
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { index = 0 }) {
                    Text("Venues")
                }
                Spacer()
                Button(action: { index = 1 }) {
                    Text("Custom Location")
                }
            }.padding([.top, .horizontal])
            
            TabView(selection: $index) {
                VStack {
                    TextField("Location name", text: $search)
                        .padding(.leading)
                        .modifier(InputField())
                        .submitLabel(.search)
                        .padding([.horizontal, .vertical])
                    
                    ScrollView {
                        VStack {
                            if venues.count > 0 {
                                ForEach(venues, id: \.id) { venue in
                                    VenueMediumListItem(item: venue)
                                        .padding(.all)
                                        .onTapGesture {
                                            manager.selectedVenues.append(venue)
                                            dismiss()
                                        }
                                }
                            } else {
                                Text("No venues found near you")
                                Button(action: { index = 1 }) {
                                    Text("Pick a custom Venue")
                                        .font(.callout)
                                }
                            }
                        }
                    }
                }.tag(0)

                VStack {
                    TextField("Location name", text: $searchModel.searchText)
                        .padding(.leading)
                        .modifier(InputField())
                        .submitLabel(.search)
                        .padding([.horizontal, .vertical])
                    
                    ScrollView {
                        switch state {
                        case .pending:
                            EmptyView()
                        case .loading:
                            ProgressView()
                        case .success:
                            if customVenues.count > 0 {
                                ForEach(customVenues, id: \.id) { venue in
                                    VenueMediumListItem(item: venue)
                                        .padding(.all)
                                        .onTapGesture {
                                            manager.selectedVenues.append(venue)
                                            dismiss()
                                        }
                                }
                            }
                        case .failure:
                            Text("Failed to look up venues")
                        }
                    }.onChange(of: searchModel.debouncedSearchText, { oldValue, newValue in
                        customVenues = [Venue]()
                        if (!newValue.isEmpty) {
                            Task {
                                await search(newValue)
                            }
                        }
                    })
                }.tag(1)
            }.tabViewStyle(.automatic)
        }
    }
}

#Preview {
    EventVenuePicker()
        .environmentObject(SessionStore())
        .environmentObject(NewEventManager())
}
