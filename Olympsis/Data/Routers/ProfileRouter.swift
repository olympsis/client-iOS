//
//  ProfileRouter.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/23/24.
//

import SwiftUI
import Foundation

class ProfileRouter: ObservableObject {
    
    @Published var navPath = NavigationPath()
    
    @MainActor
    func navigate(to destination: PROFILE_ROUTES) {
        navPath.append(destination)
    }
    
    @MainActor
    func navigateBack() {
        if (navPath.isEmpty) { return }
        navPath.removeLast()
    }
    
    @MainActor
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
