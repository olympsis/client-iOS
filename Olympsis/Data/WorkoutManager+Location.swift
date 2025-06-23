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
        guard let location = locations.filter({ location in
            return location.horizontalAccuracy <= 25.0 && location.verticalAccuracy <= 25.0
        }).last else {
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
    
    func listenToLocationUpdates() {
        Task {
            guard let routeBuilder else {
                self.log.info("Route builder not created")
                return
            }
            
            self.manager.requestWhenInUseAuthorization()
            self.manager.startUpdatingLocation()
            
            if #available(iOS 18.0, watchOS 11.0, *) {
                let session = CLServiceSession(authorization: .whenInUse, fullAccuracyPurposeKey: "fitness")
                
                for try await diagnostic in session.diagnostics {
                    if diagnostic.authorizationDenied {
                        self.log.info("Authorization denied")
                    } else if diagnostic.authorizationRestricted {
                        self.log.info("Authorization restricted")
                    } else if diagnostic.authorizationDeniedGlobally {
                        self.log.info("Authorization denied globally")
                    } else if diagnostic.authorizationRequestInProgress {
                        self.log.info("Authorization request in progress")
                    } else if diagnostic.fullAccuracyDenied {
                        self.log.info("Full accuracy denied")
                    } else if diagnostic.insufficientlyInUse {
                        self.log.info("Insufficiently in use")
                    } else if diagnostic.serviceSessionRequired {
                        self.log.info("Service session required")
                    }
                }
            }
            
            self.backgroundActivity = CLBackgroundActivitySession()
            let updates = CLLocationUpdate.liveUpdates(.fitness)
            for try await update in updates {
                guard let loc = update.location,
                      loc.horizontalAccuracy <= 25 else {
                    self.log.info("Location accuracy too low or location not recieved.")
                    return
                }
                try await routeBuilder.insertRouteData([loc])
                self.log.info("Route Location added: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
            }
        }
    }
    
    func stopListeningToLocationUpdates() {
        backgroundActivity?.invalidate()
        backgroundActivity = nil
    }
}
