//
//  TokenStore.swift
//  Olympsis
//
//  Created by Noko Anubis on 4/9/23.
//

import os
import Foundation

class TokenStore {
    
    private let log = Logger(subsystem: "com.josephlabs.olympsis", category: "token_store")
    static let account = "olmypsis"
    static let server = "api.olympsis.com"
    
    func saveTokenToKeyChain(token: String) {
        let tokenData = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: TokenStore.account,
            kSecAttrServer as String: TokenStore.server,
            kSecValueData as String: tokenData
        ]
        let update: [String: Any] = [
            kSecValueData as String: tokenData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
        
        if status == errSecSuccess {
            log.info("Token updated in Keychain successfully.")
        } else if status == errSecItemNotFound {
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            if addStatus == errSecSuccess {
                log.info("Token saved to Keychain successfully.")
            } else {
                log.error("Failed to save token to Keychain. Error: \(addStatus)")
            }
        } else {
            log.info("Failed to update token in Keychain. Error: \(status)")
        }
    }
    
    func fetchTokenFromKeyChain() -> String {
        var result: CFTypeRef?
        let fetchQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: TokenStore.server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        let fetchStatus = SecItemCopyMatching(fetchQuery as CFDictionary, &result)
        guard fetchStatus == errSecSuccess, let data = result as? Data else {
            log.error("Failed to fetch token")
            return legacyFetchToken()
        }
        guard let token = String(data: data, encoding: .utf8) else {
            log.error("Failed to decode token")
            return ""
        }
        return token
    }
    
    func legacyFetchToken() -> String {
        var result: CFTypeRef?
                let fetchQuery: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: "authToken",
                    kSecReturnData as String: kCFBooleanTrue!,
                    kSecMatchLimit as String: kSecMatchLimitOne
                ]
                let fetchStatus = SecItemCopyMatching(fetchQuery as CFDictionary, &result)
                guard fetchStatus == errSecSuccess, let data = result as? Data else { return "" }
                let fetchedToken = String(data: data, encoding: .utf8) ?? ""
                return fetchedToken
    }
    
    func clearKeyChain() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: TokenStore.account,
            kSecAttrServer as String: TokenStore.server,
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            log.error("Error deleting Keychain data: \(status)")
            return false
        }
        
        return true
    }
}
