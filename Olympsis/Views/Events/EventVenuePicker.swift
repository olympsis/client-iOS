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
    
    @State var manager: NewEventManager
    @State private var index: Int = 0
    @State private var search: String = ""
    @State private var venues: Set<Venue> = []
    @State private var customVenues = [Venue]()
    @State private var isCustomLocation: Bool = false
    @State private var state: LOADING_STATE = .pending
    
    @State private var customLocationName: String = ""
    
    @State private var mapViewModel = CustomLocationViewModel()
    @StateObject private var searchModel = VenueSearchViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private let log: Logger = Logger(
        subsystem: "com.olympsis.client",
        category: "event_venue_picker"
    )

    private func search(_ text: String) async {
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
            if points.count > 20 {
                let reduced = points.dropLast(points.count - 20)
                reduced.forEach { item in
                    guard let name = item.name,
                          let state = item.placemark.administrativeArea,
                          let city = item.placemark.subAdministrativeArea,
                          let country = item.placemark.country else {
                        return
                    }
                    let location = item.placemark.coordinate

                    self.venues.insert(
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
                    
                    self.venues.insert(
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
    
    private func saveCustomLocation() {
        guard let locationInfo = mapViewModel.locationInfo,
              !customLocationName.isEmpty && customLocationName.count > 1 else {
            return
        }

        let venue = Venue(
            id: UUID().uuidString,
            name: customLocationName,
            owner: Ownership(name: "", type: ""),
            description: "external",
            sports: [],
            images: [],
            location: GeoJSON(type: "Point", coordinates: [
                locationInfo.coordinate.longitude,
                locationInfo.coordinate.latitude
            ]),
            city: locationInfo.city, state: locationInfo.state, country: locationInfo.country)
        
        manager.selectedVenues.append(venue)
        dismiss()
    }
    
    var body: some View {
        Group {
            if !isCustomLocation {
                VStack {
                    
                    // MARK: - Actions
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isCustomLocation.toggle()
                            }
                        }) {
                            Text("Set Custom Location")
                                .font(.callout)
                                .fontWeight(.medium)
                        }
                    }.padding([.top, .horizontal])
                    
                    TextField("Location name", text: $searchModel.searchText)
                        .padding(.leading)
                        .modifier(InputFieldModifier())
                        .submitLabel(.search)
                        .padding([.horizontal, .vertical])
                    
                    ScrollView {
                        VStack {
                            if venues.count > 0 {
                                ForEach(Array(venues), id: \.id) { venue in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text(venue.name)
                                                    .font(.title2)
                                                    .lineLimit(1)
                                                
                                                if (venue.description != "external") {
                                                    Image(systemName: "checkmark.seal")
                                                        .foregroundColor(Color.Brand.quaternary)
                                                }
                                                
                                                Spacer()
                                            }
                                            Text("\(venue.city), \(venue.state)")
                                                .lineLimit(1)
                                                .foregroundStyle(.gray)
                                        }
                                        Spacer()
                                    }
                                    .padding(.all)
                                    .onTapGesture {
                                        manager.selectedVenues.append(venue)
                                        dismiss()
                                    }
                                }
                            } else {
                                Text("No venues found near you")
                                Button(action: { index = 1 }) {
                                    Text("Set a custom location")
                                        .font(.callout)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                .onChange(of: searchModel.debouncedSearchText, { oldValue, newValue in
                    venues = Set(session.venues)
                    if (!newValue.isEmpty) {
                        Task {
                            await search(newValue)
                        }
                    }
                })
            } else {
                VStack {
                    
                    // MARK: - Actions
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isCustomLocation.toggle()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                            Text("Lookup")
                        }
                        
                        Spacer()
                        
                        if mapViewModel.selectedCoordinate != nil {
                            Button(action: { saveCustomLocation() }) {
                                Text("Done")
                                    .font(.callout)
                                    .fontWeight(.medium)
                            }
                        }
                    }.padding([.top, .horizontal])
                    
                    Group {
                        if mapViewModel.selectedCoordinate != nil {
                            if let location = mapViewModel.locationInfo {
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading, spacing: 20) {
                                        TextField("Custom location name", text: $customLocationName)
                                        Text("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                                    }
                                    
                                    Button(action: { mapViewModel.clearPin() }) {
                                        Text("Clear")
                                            .fontWeight(.medium)
                                            .foregroundStyle(.red)
                                            .padding(.vertical, 5)
                                            .padding(.horizontal, 10)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(style: StrokeStyle(lineWidth: 1))
                                                    .opacity(0.5)
                                            }
                                    }
                                }
                                .padding(.all)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray)
                                        .opacity(0.12)
                                }
                                .padding(.bottom)
                            } else {
                                ProgressView()
                            }
                        } else {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text("Tap anywhere on the map to drop a pin")
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    
                                Spacer()
                            }
                            .foregroundStyle(.gray)
                        }
                    }.padding([.top, .horizontal])
                    
                    CustomLocationPicker()
                        .environment(mapViewModel)
                        .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                }
            }
        }
        .onAppear {
            venues = Set(session.venues)
        }
    }
}

#Preview {
    EventVenuePicker(manager: NewEventManager())
        .environment(SessionStore())
}
