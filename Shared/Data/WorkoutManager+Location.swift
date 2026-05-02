//
//  WorkoutManager+Location.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/3/24.
//

import Foundation
import CoreLocation

/// Location manager delegate (HealthKit route builder disabled)
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
            self.locationPoints.append(location)
            self.log.info("Location added: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }

    func listenToLocationUpdates() {
        locationTask = Task {
            // Request authorization if not already granted
            if manager.authorizationStatus == .notDetermined {
                manager.requestWhenInUseAuthorization()
            }

            manager.startUpdatingLocation()

            guard manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways else {
                self.log.error("Location authorization not granted: \(self.manager.authorizationStatus.rawValue)")
                return
            }

            do {
                self.backgroundActivity = CLBackgroundActivitySession()
                let updates = CLLocationUpdate.liveUpdates(.fitness)
                for try await update in updates {
                    guard let loc = update.location,
                          loc.horizontalAccuracy <= 25 else {
                        self.log.info("Location accuracy too low or location not recieved.")
                        continue
                    }
                    await MainActor.run {
                        self.locationPoints.append(loc)
                    }
                    self.log.info("Location added: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                }
            } catch {
                self.log.error("Failed to start listening to location updates: \(error)")
            }
        }
    }

    func stopListeningToLocationUpdates() {
        self.locationTask?.cancel()
        self.locationTask = nil
        self.backgroundActivity?.invalidate()
        self.backgroundActivity = nil
        self.manager.stopUpdatingLocation()
    }
}
