//
//  FieldObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

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
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func fetchFields() async {
        do {
            let response = try await fieldService.getFields()
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
