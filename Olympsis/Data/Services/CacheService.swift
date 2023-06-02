//
//  CacheService.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import os
import Foundation

class CacheService: ObservableObject {
    
    let log = Logger(subsystem: "com.josephlabs.olympsis", category: "cache_service")
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaults = UserDefaults()
    
    func cacheClubs(clubs:[String]) {
        self.defaults.set(clubs, forKey: "clubs")
    }
    
    func fetchClubs() -> [String] {
        return self.defaults.object(forKey: "clubs") as? [String] ?? [String]()
    }
    
    func cacheUser(user: UserData) {
        do {
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            
            self.defaults.set(data, forKey: "user")
        } catch {
            log.error("failed to store user data: \(error)")
        }
    }
    
    func fetchUser() -> UserData? {
        do {
            if let data = self.defaults.data(forKey: "user") {
                let decoder = JSONDecoder()
                let usr = try decoder.decode(UserData.self, from: data)
                return usr
            }
        } catch {
            log.error("failed to fetch user data: \(error)")
        }
        return nil
    }
    
    func cacheClubAdminToken(id: String, token: String) {
        self.defaults.set(token, forKey: id)
    }
    
    func fetchClubAdminToken(id: String) -> String {
        return self.defaults.object(forKey: id) as? String ?? ""
    }
    
    func clearCache() -> Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return false
        }
        UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        UserDefaults.standard.synchronize()
        return true
    }
}
