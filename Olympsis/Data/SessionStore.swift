//
//  SessionStore.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import SwiftUI
import Foundation

class SessionStore: ObservableObject {

    private var token: String?
    
    private var firstName: String?
    private var lastName: String?
    private var email: String?
    private var uuid: String?
    
    
    @Published var fields = [Field]()
    @Published var clubs = [Club]()
    
    @Published var clubsId = [String]()
    
    @Published var fieldsCache = [Field]()
    @Published var eventsCache = [String]()
    
    let cacheService: CacheService
    
    init() {
        cacheService = CacheService()
        fetchDataFromCache()
    }
    
    
    func fetchDataFromCache() {
        (firstName, lastName, email, uuid) = cacheService.fetchPartialUserData()
        clubsId = cacheService.fetchClubs()
    }
    
    func fetchToken() {
        self.token = cacheService.fetchToken()
    }
    
    func getFirstName() -> String {
        return firstName ?? "error";
    }
    
}
