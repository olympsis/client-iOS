//
//  LocationManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var region : MKCoordinateRegion = .init()
    
    override init(){
        super.init()
        manager.delegate = self
    }
    
    func requestLocation() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.requestLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            manager.requestLocation()
            manager.startUpdatingLocation()
        }else{
            print("Not Authorized")
        }
    }
    
    func locationManager(_manager: CLLocationManager, didFailWithError error: Error){
        print("error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else {
            print("no location")
            return
        }
        Task {
            await MainActor.run {
                self.location = location
                region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
