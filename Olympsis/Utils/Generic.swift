//
//  Generic.swift
//  Olympsis
//
//  Created by Joel on 12/26/23.
//

import CryptoKit
import Foundation


func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
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
    var metadata = NotificationMetadata()
    
    metadata.type = data["sub_type"] as? String ?? "status"
    
    metadata.userId = data["user_id"] as? String
    metadata.username = data["username"] as? String
    metadata.userImageURL = data["user_image_url"] as? String
    
    metadata.postId = data["post_id"] as? String
    metadata.postImageURL = data["post_image_url"] as? String
    
    metadata.groupId = data["group_id"] as? String
    metadata.groupName = data["group_name"] as? String
    metadata.groupImageURL = data["group_image_url"] as? String
    
    metadata.eventId = data["event_id"] as? String
    metadata.eventName = data["event_name"] as? String
    metadata.eventImageURL = data["event_image_url"] as? String
    
    metadata.url = data["url"] as? String
    
    metadata.timestamp = data["timestamp"] as? Int ?? Int(Date.now.timeIntervalSince1970)
    
    return metadata
}
