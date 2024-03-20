//
//  FieldService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Hermes
import SwiftUI
import Foundation

class FieldService {
    
    private var http: Courrier
    private let tokenStore: SecureStore
    
    init() {
        self.tokenStore = SecureStore()
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        self.http = Courrier(.HTTPS, host: host)
    }
    
    func getFields(long: Double, lat: Double, radius: Int, sports: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/fields", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: String(sports))
        ])
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
}
