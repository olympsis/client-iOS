//
//  EventVenuePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/24.
//

import os
import MapKit
import SwiftUI
import CoreLocation

struct EventVenuePicker: View {
    
    @State var manager: NewEventManager
    @State private var searchText: String = ""
    @State private var venues: Set<Venue> = []
    @State private var venuesList = [Venue]()
    @State private var showCustom: Bool = false
    @State private var state: LOADING_STATE = .pending
    
    @State private var customLocationName: String = ""
    
    @State private var mapViewModel = CustomLocationViewModel()
    @StateObject private var searchModel = VenueSearchViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private var location: MKCoordinateRegion {
        guard let user = session.user, let hometown = user.hometown else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.76553, longitude: -73.97770), latitudinalMeters: 4000, longitudinalMeters: 4000)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hometown.coordinates[1], longitude: hometown.coordinates[0]), latitudinalMeters: 4000, longitudinalMeters: 4000)
    }
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_venue_picker")
    
    private func search() {
        guard state != .loading else { return }
        
        Task { @MainActor in
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.region = session.currentLocation
            request.resultTypes = [.address, .pointOfInterest]
            
            let searchRequest = MKLocalSearch(request: request)
            
            do {
                state = .loading
                let results = try await searchRequest.start()
                let points = results.mapItems
                
                let topItems = Array(points.prefix(20))
                
                // CLGeocoder only supports one active request at a time per app, so geocode serially.
                // Results are cached in the manager so repeat searches don't re-geocode the same coords.
                let geocoder = CLGeocoder()
                var venuesFound = [Venue]()

                for item in topItems {
                    try Task.checkCancellation()

                    guard let name = item.name else { continue }
                    let coord = item.placemark.coordinate
                    let cacheKey = manager.geocodeCacheKey(lat: coord.latitude, lon: coord.longitude)

                    // Resolve geocode info: use cache if available, otherwise hit the geocoder
                    let geocodeResult: NewEventManager.GeocodeResult
                    if let cached = manager.geocodeCache[cacheKey] {
                        geocodeResult = cached
                    } else {
                        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                        let placemark: CLPlacemark?
                        do {
                            placemark = try await geocoder.reverseGeocodeLocation(location).first
                        } catch {
                            // Skip this result if geocoding fails (e.g. rate limit or network hiccup)
                            log.warning("Geocoding failed for \(name): \(error.localizedDescription)")
                            continue
                        }
                        guard let placemark else { continue }

                        let city = placemark.locality ?? placemark.subAdministrativeArea ?? ""
                        let stateStr = placemark.administrativeArea ?? ""
                        let country = placemark.country ?? ""

                        guard !city.isEmpty, !stateStr.isEmpty, !country.isEmpty else { continue }

                        // Build fullAddress as two lines:
                        //   Line 1: "StreetNumber StreetName"
                        //   Line 2: "City, StateAbbrev PostalCode, Country"
                        let fullAddress: String? = {
                            var line1 = ""
                            if let street = placemark.thoroughfare, !street.isEmpty {
                                line1 = placemark.subThoroughfare.map { "\($0) \(street)" } ?? street
                            }
                            var line2Parts: [String] = []
                            if !city.isEmpty { line2Parts.append(city) }
                            var regionPostal = stateStr
                            if let postalCode = placemark.postalCode, !postalCode.isEmpty {
                                regionPostal = regionPostal.isEmpty ? postalCode : "\(regionPostal) \(postalCode)"
                            }
                            if !regionPostal.isEmpty { line2Parts.append(regionPostal) }
                            if !country.isEmpty { line2Parts.append(country) }
                            let line2 = line2Parts.joined(separator: ", ")
                            let combined = line1.isEmpty ? line2 : (line2.isEmpty ? line1 : "\(line1)\n\(line2)")
                            return combined.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : combined
                        }()

                        let result = NewEventManager.GeocodeResult(city: city, state: stateStr, country: country, fullAddress: fullAddress)
                        manager.geocodeCache[cacheKey] = result
                        geocodeResult = result
                    }

                    venuesFound.append(Venue(
                        name: name,
                        location: GeoJSON(
                            type: "Point",
                            coordinates: [Double(coord.longitude), Double(coord.latitude)]
                        ),
                        city: geocodeResult.city,
                        state: geocodeResult.state,
                        country: geocodeResult.country,
                        fullAddress: geocodeResult.fullAddress
                    ))
                }
                
                // Merge and refresh UI (on main actor)
                self.venues.formUnion(venuesFound)
                self.venuesList = filterResults()
                state = .success
            } catch is CancellationError {
                // User navigated away or search replaced; treat as benign.
                state = .pending
            } catch {
                log.error("Failed to search for venues: \(error.localizedDescription)")
                state = .failure
            }
        }
    }
    
    private func filterResults() -> [Venue] {
        // Exclude venues the user has already selected
        let selectedNames = Set(manager.selectedVenueDescriptors.compactMap { $0.name?.localizedLowercase })
        let list = Array(venues).filter { !selectedNames.contains($0.name.localizedLowercase) }
        let userCoord = session.currentLocation.center
        let userLocation = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        
        // Helper to compute distance in meters from user to a venue
        func distanceToVenue(_ v: Venue) -> CLLocationDistance {
            // GeoJSON coordinates are [lon, lat]
            guard v.location.coordinates.count >= 2 else { return .greatestFiniteMagnitude }
            let lat = v.location.coordinates[1]
            let lon = v.location.coordinates[0]
            let venueLoc = CLLocation(latitude: lat, longitude: lon)
            return userLocation.distance(from: venueLoc)
        }
        
        // Normalize comparison strings
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasQuery = !query.isEmpty
        
        let sorted = list.sorted { a, b in
            // Primary: custom venues first (description == "external")
            let aIsCustom = a.description == "external"
            let bIsCustom = b.description == "external"
            if aIsCustom != bIsCustom {
                return aIsCustom && !bIsCustom
            }
            
            // Secondary: name similarity (lower Levenshtein is better)
            let aName = a.name.localizedLowercase
            let bName = b.name.localizedLowercase
            let q = query.localizedLowercase
            
            let aLev = hasQuery ? levenshteinDistance(stringA: aName, stringB: q) : 0
            let bLev = hasQuery ? levenshteinDistance(stringA: bName, stringB: q) : 0
            
            if aLev != bLev {
                return aLev < bLev
            }
            
            // Tertiary: distance to user (lower is better)
            let aDist = distanceToVenue(a)
            let bDist = distanceToVenue(b)
            if aDist != bDist {
                return aDist < bDist
            }
            
            // Final tie-breaker: alphabetical by name
            return aName < bName
        }
        
        // Return only the top 20 results
        return Array(sorted.prefix(20))
    }
    
    private func saveCustomLocation() {
        guard let locationInfo = mapViewModel.locationInfo,
              !locationInfo.name.isEmpty && locationInfo.name.count > 1 else {
            return
        }

        let venue = Venue(
            id: UUID().uuidString,
            name: locationInfo.name,
            owner: Ownership(name: "", type: ""),
            description: "external",
            sports: [],
            images: [],
            location: GeoJSON(type: "Point", coordinates: [
                locationInfo.coordinate.longitude,
                locationInfo.coordinate.latitude
            ]),
            city: locationInfo.city,
            state: locationInfo.state,
            country: locationInfo.country
        )
        
        manager.addVenueDescriptor(venue)
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                switch state {
                case .pending, .success:
                    if venuesList.count > 0 {
                        ForEach(venuesList, id: \.id) { venue in
                            VenuePickerListItem(venue: venue, isExternal: venue.description != "external")
                                .padding([.horizontal, .bottom])
                                .onTapGesture {
                                    manager.addVenueDescriptor(venue)
                                    dismiss()
                                }
                        }
                    } else {
                        VStack {
                            Text(String(localized: "event-search-locations-or", table: "Events"))
                            Button(action: { showCustom.toggle() }) {
                                Text(String(localized: "set-custom-location-text", table: "Events"))
                                    .font(.callout)
                                    .fontWeight(.medium)
                            }
                        }.padding(.top, 50)
                    }
                case .loading:
                    ProgressView()
                        .padding(.top, 50)
                case .failure:
                    VStack {
                        Text(String(localized: "event-search-locations-or", table: "Events"))
                        Button(action: { showCustom.toggle() }) {
                            Text(String(localized: "set-custom-location-text", table: "Events"))
                                .font(.callout)
                                .fontWeight(.medium)
                        }
                    }.padding(.top, 50)
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search, {
                search()
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26.0, *) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                        }
                    } else {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showCustom.toggle() }) {
                        Image("icons/custom.map.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showCustom) {
                saveCustomLocation()
            } content: {
                NewEventCustomLocation()
                    .environment(mapViewModel)
            }
            .onAppear {
                venues.formUnion(session.venues)
                venuesList = filterResults()
            }
        }
    }
}

#Preview {
    EventVenuePicker(manager: NewEventManager())
        .environment(SessionStore())
}
