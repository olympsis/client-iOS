//
//  TokenStore.swift
//  Olympsis
//
//  Created by Noko Anubis on 4/9/23.
//

import os
import Foundation

class TokenStore {
    
    let log = Logger(subsystem: "com.josephlabs.olympsis", category: "token_store")
    let tokenKey: String = "authToken"
    
    func saveTokenToKeyChain(token: String) {
        let tokenData = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
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
    
    func clearKeyChain() -> Bool {
        guard let bundle = Bundle.main.bundleIdentifier else {
            log.error("Failed to get bundle identifier")
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: bundle,
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            log.error("Error deleting Keychain data: \(status)")
            return false
        }
        
        return true
    }
}
