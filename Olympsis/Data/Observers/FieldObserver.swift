//
//  FieldObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI
import Foundation

/// Field Observer is a class object that keeps tracks of and fetches fields
class FieldObserver: ObservableObject{
    private let decoder: JSONDecoder
    private let fieldService: FieldService
    
    @Published var isLoading = true
    @Published var fieldsCount = 0
    @Published var fields = [Field]()
    
    init(){
        decoder = JSONDecoder()
        fieldService = FieldService()
    }
    
    /// Calls the field service to get fields based on certain params
    /// - Parameter longitude: `Double`
    /// - Parameter latitude: `Double`
    /// - Parameter radius: `Int`
    func fetchFields(longitude: Double, latitude: Double, radius: Int) async {
        do {
            let response = try await fieldService.getFields(long: longitude, lat: latitude, radius: radius)
            let object = try decoder.decode(FieldsResponse.self, from: response)
            await MainActor.run { // TODO: Check later about threads
                self.fields = object.fields
                self.fieldsCount = object.totalFields
            }
        } catch (let err) {
            print(err)
        }
    }
}
