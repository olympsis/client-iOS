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
    private let tokenStore = TokenStore()
    
    init() {
        let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        let key = Bundle.main.object(forInfoDictionaryKey: "API-KEY") as? String ?? ""
        self.http = Courrier(host: host, apiKey: key, token: tokenStore.FetchTokenFromKeyChain())
    }
    
    func getFields(long: Double, lat: Double, radius: Int, sports: String) async throws -> Data {
        let endpoint = Endpoint(path: "/fields", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: String(sports))
        ])
        
        let (data, _) = try await http.Request(endpoint: endpoint, method: .GET)
        return data
    }
}
