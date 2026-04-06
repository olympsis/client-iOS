//
//  CacheService.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import os
import Foundation

class CacheService: ObservableObject {
    
    let log = Logger(subsystem: "com.olympsis.client", category: "cache_service")
    let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    let defaults = UserDefaults()
    
    func cacheClubs(clubs:[String]) {
        self.defaults.set(clubs, forKey: "clubs")
    }
    
    func fetchClubs() -> [String] {
        return self.defaults.object(forKey: "clubs") as? [String] ?? [String]()
    }
    
    func cacheUser(user: User) {
        do {
            
            let data = try encoder.encode(user)
            
            self.defaults.set(data, forKey: "user")
        } catch {
            log.error("failed to store user data: \(error)")
        }
    }
    
    func fetchUser() -> User? {
        do {
            if let data = self.defaults.data(forKey: "user") {
                let usr = try decoder.decode(User.self, from: data)
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
    
    func clearCache() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return
        }
        UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        UserDefaults.standard.synchronize()
        return
    }
}
