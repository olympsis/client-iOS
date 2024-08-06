//
//  FieldObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import os
import SwiftUI
import Foundation

/// Field Observer is a class object that keeps tracks of and fetches fields
class FieldObserver: ObservableObject{
    private let decoder = JSONDecoder()
    private let fieldService = FieldService()
    private let log = Logger(subsystem: "com.olympsis.client", category: "field_observer")
    
    /// Calls the venue service to get venues based on certain params
    /// - Parameter longitude: `Double` longitudonal meters of location
    /// - Parameter latitude: `Double` latitudonal memters of location
    /// - Parameter radius: `Int` radius of surface area for search
    /// - Returns: a `[Venue]` an optional venue array containing the venues in that location
    func fetchFields(longitude: Double, latitude: Double, radius: Int, sports: String) async -> [Venue]? {
        do {
            let (data, resp) = try await fieldService.getVenues(long: longitude, lat: latitude, radius: radius, sports: sports)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(VenuesResponse.self, from: data)
            return object.fields
        } catch {
            log.error("Failed to fetch venues: \(error)")
        }
        return nil
    }
    
    /// Calls the venue service to get a specific venue by it's ID
    /// - Parameter id: `String` id of the venue
    /// - Returns:  a `Venue` optional in case we fail to get venue
    func fetchVenue(id: String) async -> Venue? {
        do {
            let (data, resp) = try await fieldService.getVenue(id: id)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(Venue.self, from: data)
            return object
        } catch {
            log.error("Failed to fetch venue: \(error.localizedDescription)")
        }
        return nil
    }
}
