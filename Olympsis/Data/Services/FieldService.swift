//
//  FieldService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Hermes
import SwiftUI
import Foundation
import FirebaseAuth

class FieldService {
    
    private var http: Courrier
    
    init() {
        #if DEBUG
            self.http = Courrier(.HTTP, host: "localhost")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
    }
    
    func getFields(long: Double, lat: Double, radius: Int, sports: String) async throws -> (Data, URLResponse) {
        let token = try await Auth.auth().currentUser?.getIDToken()
        let endpoint = Endpoint("/v1/fields", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: String(sports))
        ])
        
        return try await http.Request(.GET, endpoint, headers: ["Authorization": token ?? ""])
    }
}
