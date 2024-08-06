//
//  WorkoutManager+Location.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/3/24.
//

import Foundation
import CoreLocation

/// Attempted workaround of ios18 location request issues
extension WorkoutManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        self.log.error("error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            self.log.error("No location found")
            return
        }
        Task { @MainActor in
            guard let routeBuilder else {
                return
            }
            try await routeBuilder.insertRouteData([location])
            self.log.info("Route Location added: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
}
