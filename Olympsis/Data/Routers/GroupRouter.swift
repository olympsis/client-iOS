//
//  GroupRouter.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/23/24.
//

import SwiftUI
import Foundation

class GroupRouter: ObservableObject {
    
    @Published var navPath = NavigationPath()
    
    @MainActor
    func navigate(to destination: GROUP_ROUTES) {
        navPath.append(destination)
    }
    
    @MainActor
    func navigateBack() {
        navPath.removeLast()
    }
    
    @MainActor
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
