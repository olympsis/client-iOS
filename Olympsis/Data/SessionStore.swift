//
//  SessionStore.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import SwiftUI
import Foundation

class SessionStore: ObservableObject {
    
    private var firstName: String?
    private var lastName: String?
    private var email: String?
    
    let cacheService: CacheService
    
    init() {
        cacheService = CacheService()
        fetchDataFromCache()
    }
    
    
    func fetchDataFromCache() {
        (firstName, lastName, email, _) = cacheService.fetchPartialUserData()
    }
    
    func getFirstName() -> String {
        return firstName ?? "error";
    }
}
