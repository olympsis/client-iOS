//
//  LocationObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import MapKit
import Foundation
import CoreLocation

class LocationObserver: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var manager = CLLocationManager()
    @Published var region: MKCoordinateRegion = .init()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        manager.pausesLocationUpdatesAutomatically = true
    }
    
    // request authorization from user and starts updating location
    func requestAuthorization() async throws {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func isLocationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    // error if user declines
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // update user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else {
            return
        }
        region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
    
    // did enter region event
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let _ = region as? CLCircularRegion {
        }
    }
}
