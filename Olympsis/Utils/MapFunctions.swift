//
//  MapFunctions.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/29/24.
//

import Foundation
import CoreLocation

func getPlacemark(from coordinates: CLLocationCoordinate2D, completion: @escaping (CLPlacemark?) -> Void) {
    let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    let geocoder = CLGeocoder()
    
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
        if let error = error {
            print("Reverse geocoding failed with error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        if let placemark = placemarks?.first {
            completion(placemark)
        } else {
            print("No placemark found")
            completion(nil)
        }
    }
}
