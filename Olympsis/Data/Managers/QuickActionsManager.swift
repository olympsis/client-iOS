//
//  QuickActionsManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/28/25.
//

import os
import UIKit
import Foundation

enum QuickAction: String, CaseIterable {
    case deleteFeedback
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .deleteFeedback:
            return "Deleting Olympsis?"
        }
    }
    
    var subtitle: String {
        switch self {
        case .deleteFeedback:
            return "Would you share some feedback?"
        }
    }
    
    var icon: UIApplicationShortcutIcon {
        switch self {
        case .deleteFeedback:
            return UIApplicationShortcutIcon(systemImageName: "hand.wave")
        }
    }
    
    var item: UIApplicationShortcutItem {
        return UIApplicationShortcutItem(
            type: id,
            localizedTitle: title,
            localizedSubtitle: subtitle,
            icon: icon,
            userInfo: nil
        )
    }
}

class QuickActionsManager: ObservableObject {
    static let shared = QuickActionsManager()
    @Published var quickAction: QuickAction? = nil
    private let logger = Logger(subsystem: "com.olympsis.client", category: "quick_actions_manager")
    
    private init() {}
    
    func setupShortcuts() {
        UIApplication.shared.shortcutItems = [QuickAction.deleteFeedback.item]
    }
    
    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let action = QuickAction(rawValue: shortcutItem.type) else {
            logger.error("Failed to parse shortcut item.")
            return false
        }
        
        // Store the action
        quickAction = action
        
        // Handle the action
        switch action {
        case .deleteFeedback:
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
            let subject = "Delete Feedback v\(appVersion) b\(buildNumber)"
            let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            if let url = URL(string: "mailto:support@olympsis.com?subject=\(encodedSubject)") {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                logger.error("Failed to construct email URL")
                return false
            }
            
            return true
        }
    }
}

// Extension to get app version information
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
