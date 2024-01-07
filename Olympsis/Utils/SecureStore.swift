//
//  TokenStore.swift
//  Olympsis
//
//  Created by Noko Anubis on 4/9/23.
//

import os
import Foundation

class SecureStore {
    
    static let account = "olmypsis"
    static let server = "api.olympsis.com"
    private let log = Logger(subsystem: "com.josephlabs.olympsis", category: "secure_store")
    
    func saveCurrentUserID(uuid: String) {
        guard let uuidData = uuid.data(using: .utf8) else {
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "apple",
            kSecValueData as String: uuidData
        ]
        
        // just in case
        SecItemDelete(query as CFDictionary)
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        if addStatus == errSecSuccess {
            log.info("userID saved to keychain successfully.")
        } else {
            log.error("failed to save UserID to keychain. Error: \(addStatus)")
        }
    }
    
    func fetchCurrentUserID() -> String? {
        var result: CFTypeRef?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "apple",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        let fetchStatus = SecItemCopyMatching(query as CFDictionary, &result)
        guard fetchStatus == errSecSuccess, let data = result as? Data else {
            log.error("failed to get userID")
            return nil
        }
        guard let userID = String(data: data, encoding: .utf8) else {
            log.error("failed to decode userID")
            return nil
        }
        return userID
    }
    
    func saveTokenToKeyChain(token: String) {
        guard let tokenData = token.data(using: .utf8) else {
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: SecureStore.account,
            kSecAttrServer as String: SecureStore.server,
            kSecValueData as String: tokenData
        ]
        let update: [String: Any] = [
            kSecValueData as String: tokenData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
        
        if status == errSecSuccess {
            log.info("token updated in keychain successfully.")
        } else if status == errSecItemNotFound {
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            if addStatus == errSecSuccess {
                log.info("token saved to keychain successfully.")
            } else {
                log.error("failed to save token to keychain. Error: \(addStatus)")
            }
        } else {
            log.info("failed to update token in keychain. Error: \(status)")
        }
    }
    
    func fetchTokenFromKeyChain() -> String {
        var result: CFTypeRef?
        let fetchQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: SecureStore.account,
            kSecAttrServer as String: SecureStore.server,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        let fetchStatus = SecItemCopyMatching(fetchQuery as CFDictionary, &result)
        guard fetchStatus == errSecSuccess, let data = result as? Data else {
            log.error("Failed to fetch token")
            return ""
        }
        guard let token = String(data: data, encoding: .utf8) else {
            log.error("Failed to decode token")
            return ""
        }
        return token
    }
    
    func clearKeyChain() {
        // auth token
        var query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: SecureStore.account,
            kSecAttrServer as String: SecureStore.server,
        ]
        
        var status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            log.error("error deleting keychain data: \(status)")
        }
        
        
        // user id
        query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "apple",
        ]
        status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            log.error("error deleting keychain data: \(status)")
        }
        
        // legacy token
        query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
        ]
        status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            log.error("error deleting keychain data: \(status)")
        }
    }
}
