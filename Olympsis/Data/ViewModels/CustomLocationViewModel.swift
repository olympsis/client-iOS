//
//  CustomLocationViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/4/25.
//

import MapKit
import SwiftUI

struct LocationInfo {
    var name: String
    var coordinate: CLLocationCoordinate2D
    var city: String
    var state: String
    var country: String
}

@Observable
class CustomLocationViewModel {
    
    var isLoading = false
    var locationInfo: LocationInfo?
    var selectedCoordinate: CLLocationCoordinate2D?
        
    func lookupLocationInfo(for coordinate: CLLocationCoordinate2D) {
            isLoading = true
            locationInfo = nil
            selectedCoordinate = coordinate
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    guard let self = self,
                          let placemark = placemarks?.first,
                          error == nil else { return }
                    
                    let city = placemark.locality ?? "Unknown"
                    let state = placemark.administrativeArea ?? "Unknown"
                    let country = placemark.country ?? "Unknown"
                    
                    self.locationInfo = LocationInfo(
                        name: "Custom Location",
                        coordinate: coordinate,
                        city: city,
                        state: state,
                        country: country
                    )
                }
            }
        }
        
    func clearPin() {
        selectedCoordinate = nil
        locationInfo = nil
    }
}
