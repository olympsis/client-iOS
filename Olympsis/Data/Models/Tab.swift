//
//  Tab.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import Foundation

enum Tab: String, CaseIterable {
    case home = "Home"
    case club = "Club"
    case map = "Map"
    case messages = "Messages"
    case profile = "Setting"
}

enum AuthTab: String, CaseIterable {
    case auth = "AUTH"
    case create = "CREATE"
    case permissions = "PERMISSIONS"
}
