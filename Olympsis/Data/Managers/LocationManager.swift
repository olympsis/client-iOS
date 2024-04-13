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

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var region : MKCoordinateRegion = .init()
    
    @AppStorage("latitude") private var latitude: Double?
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
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func changeLocationRegion(location: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse:  // Location services are available.
                manager.startMonitoringSignificantLocationChanges()
                break
                
            case .restricted, .denied:  // Location services currently unavailable.
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
                manager.requestWhenInUseAuthorization()
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
