//
//  Generic.swift
//  Olympsis
//
//  Created by Joel on 12/26/23.
//

import os
import SwiftUI
import CryptoKit
import Foundation


func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        Logger(subsystem: "com.olympsis.client", category: "generic")
            .error("SecRandomCopyBytes failed with OSStatus \(errorCode), falling back to UUID")
        return UUID().uuidString
    }

    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

    let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
    }

    return String(nonce)
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()

    return hashString
}

// MARK: - Notification Metadata
func generateMetadata(data: [AnyHashable : Any]) -> NotificationMetadata {
    var metadata = NotificationMetadata(type: .clubApplicationUpdate)
    
    metadata.userID = data["user_id"] as? String
    metadata.username = data["username"] as? String
    metadata.userImageURL = data["user_image_url"] as? String
    
    metadata.postID = data["post_id"] as? String
    metadata.postImageURL = data["post_image_url"] as? String
    
    metadata.groupID = data["group_id"] as? String
    metadata.groupName = data["group_name"] as? String
    metadata.groupImageURL = data["group_image_url"] as? String
    
    metadata.eventID = data["event_id"] as? String
    metadata.eventName = data["event_name"] as? String
    metadata.eventImageURL = data["event_image_url"] as? String
    
    return metadata
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
