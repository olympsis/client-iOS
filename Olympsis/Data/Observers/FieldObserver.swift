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
    private let log = Logger(subsystem: "com.josephlabs.olympsis", category: "field_observer")
    
    /// Calls the field service to get fields based on certain params
    /// - Parameter longitude: `Double`
    /// - Parameter latitude: `Double`
    /// - Parameter radius: `Int`
    func fetchFields(longitude: Double, latitude: Double, radius: Int, sports: String) async -> [Field]? {
        do {
            let (data, resp) = try await fieldService.getFields(long: longitude, lat: latitude, radius: radius, sports: sports)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(FieldsResponse.self, from: data)
            return object.fields
        } catch {
            log.error("\(error)")
        }
        return nil
    }
}
