//
//  VenueSmallListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/4/24.
//

import os
import MapKit
import SwiftUI

struct VenueDescriptorView: View {
    
    var item: VenueDescriptor
    
    @State private var venue: Venue?
    @State private var name: String?
    @State private var showVenue: Bool = false
    @State private var camera: MapCameraPosition
    @State private var location: CLLocationCoordinate2D
    
    @EnvironmentObject private var session: SessionStore
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "venue_small_list_item")
    
    init(item: VenueDescriptor) {
        self.item = item
        self.name = item.name
        
        if let coordinates = item.location?.coordinates {
            self.camera = MapCameraPosition.camera(
                MapCamera(centerCoordinate: CLLocationCoordinate2D(
                    latitude: coordinates[1], longitude: coordinates[0]
                ), distance: 1000)
            )
        } else {
            self.camera = MapCameraPosition.camera(
                MapCamera(centerCoordinate: CLLocationCoordinate2D(
                    latitude: 37.3347302, longitude: -122.0089189
                ), distance: 1000 )
            )
        }
        
        if let coordinates = item.location?.coordinates {
            self.location = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
        } else {
            self.location = CLLocationCoordinate2D(latitude: 37.3347302, longitude: -122.0089189)
        }
    }
    
    func loadVenue() async -> Venue? {
        guard item.isInternal() else {
            guard let coordinates = item.location?.coordinates else {
                return nil
            }
            await UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(coordinates[1]),\(coordinates[0])")! as URL)
            return nil
        }
        guard let venue = await fetchVenue() else {
            return nil
        }
        return venue
    }
    
    /// We want to dynamically fetch the venue information to reduce the amount of data we're holding in memory
    ///
    /// We try to fetch the venue locally in memory if we have it stored and if it's an Olympsis vetted location.
    /// If we do not have the venue in memory we will try to fetch it remotely.
    /// If that fails then we will have to display an error.
    ///
    /// If the venue is not Olympsis vetted we will simply just open maps at the provided coordinates
    func fetchVenue() async -> Venue? {
        if (item.isInternal()) {
            guard let resp = await fetchVenueLocal() else {
                guard let resp = await fetchVenueRemote() else {
                    return nil
                }
                return resp
            }
            return resp
        }
        return nil
    }
    
    /// Fetch the venue from the data we have in memory
    /// - Returns: a `Venue` optional object in case we failt to find venue
    func fetchVenueLocal() async -> Venue? {
        guard let id = item.id,
              let venue = session.venues.first(where: { $0.id == id }) else {
            log.error("Failed to verify venue data or venue is not stored locally")
            return nil
        }
        return venue
    }
    
    /// Fetch the venue from the server
    /// - Returns: a `Venue` optinal object in case the server fails to find venue
    func fetchVenueRemote() async -> Venue? {
        guard let id = item.id,
              let venue = await session.fieldObserver.fetchVenue(id: id) else {
            log.error("Failed to verify venue data to fetch remotely")
            return nil
        }
        session.venues.append(venue)
        return venue
    }
    
    var body: some View {
        Group {
            Map(position: $camera, interactionModes: .pan) {
                Marker(name ?? "Venue", coordinate: location)
            }
            .disabled(true)
            .frame(height: 100)
            .mapStyle(.standard(elevation: .realistic))
            .cornerRadius(radius: 10, corners: .allCorners)
        }
        .task {
            guard let v = await fetchVenue() else {
                return
            }
            self.venue = v
            self.name = v.name
            self.location = CLLocationCoordinate2D(latitude: v.location.coordinates[1], longitude: v.location.coordinates[0])
            self.camera = MapCameraPosition.camera(MapCamera(centerCoordinate: self.location, distance: 1000))
        }
        .onTapGesture {
            self.showVenue.toggle()
        }
        .sheet(isPresented: $showVenue) {
            if let v = venue {
                VenueView(venue: v)
            }
        }
    }
}

#Preview {
    VenueDescriptorView(item: VENUE_DESCRIPTORS[1])
        .environmentObject(SessionStore())
}
