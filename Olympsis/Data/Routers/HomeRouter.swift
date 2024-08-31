//
//  HomeRouter.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/23/24.
//

import SwiftUI
import Foundation


class HomeRouter: ObservableObject {
    
    @Published var navPath = NavigationPath()
    
    @MainActor
    func navigate(to destination: HOME_ROUTES) {
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
