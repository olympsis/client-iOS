//
//  TokenStore.swift
//  Olympsis
//
//  Created by Noko Anubis on 4/9/23.
//

import Foundation

class TokenStore {
    
    let tokenKey: String = "authToken"
    
    func SaveTokenToKeyChain(token: String) -> Bool {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { return false }
        return true
    }
    
    func FetchTokenFromKeyChain() -> String {
        var result: AnyObject?
        let fetchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        let fetchStatus = SecItemCopyMatching(fetchQuery as CFDictionary, &result)
        guard fetchStatus == errSecSuccess, let data = result as? Data else { return "" }
        let fetchedToken = String(data: data, encoding: .utf8) ?? ""
        return fetchedToken
    }
}
