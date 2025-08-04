//
//  FinanceService.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/31/25.
//

import Hermes
import Foundation

class FinanceService {
    
    private var http: Courrier
    private let decoder: JSONDecoder
    
    init() {
        #if targetEnvironment(simulator)
            self.http = Courrier(.HTTP, host: "localhost")
        #else
            let host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
            self.http = Courrier(.HTTPS, host: host)
        #endif
        
        decoder = JSONDecoder()
    }
    
    func getAccountOverview(clubID: String) async throws {}
    func getTransactionHistory(clubID: String, skip: Int = 0, limit: Int = 20) {}
    func getCustomerSheet(clubID: String) {}
    
    func initiatePayout(clubID: String, amount: Double) {}
}
