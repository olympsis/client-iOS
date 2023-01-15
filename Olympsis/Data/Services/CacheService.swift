//
//  CacheService.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import Foundation

class CacheService: ObservableObject {
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let defaults: UserDefaults
    
    init() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        defaults = UserDefaults()
    }
    
    func cacheToken(token: String) async {
        self.defaults.set(token, forKey: "token")
    }
    
    func fetchToken() -> String {
        guard let token = self.defaults.string(forKey: "token") else {
            return ""
        }
        return token
    }
    
    func chacheIdentifiableData(firstName: String, lastName: String, email: String) async {
        self.defaults.set(firstName, forKey: "firstName")
        self.defaults.set(lastName, forKey: "lastName")
        self.defaults.set(email, forKey: "email")
    }
    
    func fetchIdentifiableData() -> (String, String, String) {
        let f = self.defaults.string(forKey: "firstName") ?? ""
        let l = self.defaults.string(forKey: "lastName") ?? ""
        let e = self.defaults.string(forKey: "email") ?? ""
        
        return (f, l, e)
    }
        
    func cacheClubs(clubs:[String]) async {
        self.defaults.set(clubs, forKey: "clubs")
    }
    
    func fetchClubs() -> [String] {
        return self.defaults.object(forKey: "clubs") as? [String] ?? [String]()
    }
    
    func cacheUser(user: UserStore) async {
        do {
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            
            self.defaults.set(data, forKey: "user")
        } catch {
            print("failed to store user data: \(error)")
        }
    }
    
    func fetchUser() -> UserStore? {
        do {
            if let data = self.defaults.data(forKey: "user") {
                let decoder = JSONDecoder()
                let usr = try decoder.decode(UserStore.self, from: data)
                return usr
            }
        } catch {
            print("failed to fetch user data: \(error)")
        }
        return nil
    }
}
