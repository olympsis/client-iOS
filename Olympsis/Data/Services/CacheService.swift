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
    
    func cachePartialUserData(firstName: String, lastName: String, email: String, uuid: String) async {
        self.defaults.set(firstName, forKey: "firstName")
        self.defaults.set(lastName, forKey: "lastName")
        self.defaults.set(email, forKey: "email")
        self.defaults.set(uuid, forKey: "uuid")
    }
    
    func fetchPartialUserData() -> (String, String, String, String) {
        let fN = self.defaults.string(forKey: "firstName") ?? ""
        let lN = self.defaults.string(forKey: "lastName") ?? ""
        let em = self.defaults.string(forKey: "email") ?? ""
        let ud = self.defaults.string(forKey: "uuid") ?? ""
        
        return (fN, lN, em, ud)
    }
        
    func cacheClubs(clubs:[String]) async {
        self.defaults.set(clubs, forKey: "clubs")
    }
    
    func fetchClubs() -> [String] {
        return self.defaults.object(forKey: "clubs") as? [String] ?? [String]()
    }
    
    func cacheUser(user: UserStore) async {
        self.defaults.set(user, forKey: "user")
    }
    
    func fetchUser() -> UserStore? {
        return self.defaults.object(forKey: "user") as? UserStore
    }
}
