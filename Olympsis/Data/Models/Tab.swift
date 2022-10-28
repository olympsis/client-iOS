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
    case tournament = "Tournament"
    case setting = "Setting"
    
    func getIcon() -> String {
        switch(self){
        case .home:
            return "house"
        case .club:
            return "person.2"
        case .map:
            return "map"
        case .tournament:
            return "crown"
        case .setting:
            return "gearshape"
        }
    }
}

enum AuthTab: String, CaseIterable {
    case auth = "AUTH"
    case create = "CREATE"
    case permissions = "PERMISSIONS"
}
