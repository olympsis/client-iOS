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
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
        decoder = JSONDecoder()
    }
    
    func getAccountOverview(clubID: String) async throws {}
    func getTransactionHistory(clubID: String, skip: Int = 0, limit: Int = 20) {}
    func getCustomerSheet(clubID: String) {}
    
    func initiatePayout(clubID: String, amount: Double) {}
}
