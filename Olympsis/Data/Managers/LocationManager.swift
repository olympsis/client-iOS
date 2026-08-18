//
//  LocationManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import os
import MapKit
import SwiftUI
import Foundation
import CoreLocation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    var manager = CLLocationManager()
    var location: CLLocationCoordinate2D? // Last known location
    var region : MKCoordinateRegion = .init()
    
    var isLocationAuthorized: Bool = false
    var isLocationServicesEnabled: Bool = false
    
    @ObservationIgnored
    @AppStorage("latitude") private var latitude: Double?
    @ObservationIgnored
    @AppStorage("longitude") private var longitude: Double?
    
    var logger: Logger = Logger(subsystem: "com.olympsis.client", category: "location_manager")
    
    var isAuthorized: Bool {
        switch (manager.authorizationStatus) {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined, .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    override init(){
        super.init()
        manager.delegate = self
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        startUpdatingLocationIfAuthorized()
    }

    /// Starts a location update only when access was already granted. This is
    /// safe for background initialization because it never presents the system
    /// location permission prompt.
    func startUpdatingLocationIfAuthorized() {
        guard isAuthorized else { return }
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // Use continuous updates (not significant-change monitoring): the
        // latter never delivers a fix for a static Simulator location, which
        // left `location` nil and forced the map/search to fall back to the
        // hometown. `startUpdatingLocation` fires `didUpdateLocations` for the
        // current (including simulated) position.
        manager.startUpdatingLocation()
    }

    /// Wait up to `timeout` seconds for the first location fix to land in
    /// `location`. Polls every 50 ms (cheap enough at this cadence and keeps
    /// the implementation independent of the delegate callback). Returns the
    /// coordinate if one arrived in time, otherwise `nil` so callers can
    /// decide whether to fall back to a stored hometown / default location.
    @MainActor
    func waitForLocation(timeout: TimeInterval = 1.0) async -> CLLocationCoordinate2D? {
        // Already have a fix — no need to wait.
        if let loc = location { return loc }

        let deadline = Date().addingTimeInterval(timeout)
        let pollNanos: UInt64 = 50_000_000 // 50 ms

        while Date() < deadline {
            if let loc = location { return loc }
            do {
                try await Task.sleep(nanoseconds: pollNanos)
            } catch {
                // Task cancelled — bail out with whatever we have.
                return location
            }
        }
        return location
    }
    
    func changeLocationRegion(location: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:  // Location services are available.
                isLocationAuthorized = true
                isLocationServicesEnabled = true
                manager.startUpdatingLocation()
                break
                
            case .restricted, .denied:  // Location services currently unavailable.
            isLocationAuthorized = false
            isLocationServicesEnabled = false
                guard let lat = latitude,
                      let long = longitude else {
                    // We will use apple park as the fallback location
                    let loc = CLLocationCoordinate2D(latitude: 37.334886, longitude: -122.008988)
                    region = MKCoordinateRegion(center: loc, latitudinalMeters: 10000, longitudinalMeters: 10000)
                    return
                }
                
                // if the user has a hometown we will go there
                let loc = CLLocationCoordinate2D(latitude: lat, longitude: long)
                region = MKCoordinateRegion(center: loc, latitudinalMeters: 10000, longitudinalMeters: 10000)
                break
                
            case .notDetermined:        // Authorization not determined yet.
                isLocationAuthorized = false
                isLocationServicesEnabled = true
                break
                
            default:
                break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        logger.error("error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else {
            logger.error("no location")
            return
        }
        Task {
            await MainActor.run {
                self.location = location
                region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            }
        }
    }
}
