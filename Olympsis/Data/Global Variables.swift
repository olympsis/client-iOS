//
//  Global Variables.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import UIKit
import Foundation

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

enum USER_STATUS {
    case New
    case Banned
    case Ubanned
    case Returning
    case Unknown
}


enum NavigationType: String, Hashable {
    case home = "HOME"
    case clubs = "CLUBS"
    case map = "MAP"
    case settings = "SETTINGS"
}


enum AuthNavigation: String, Hashable {
    case auth = "AUTH"
    case new = "NEW"
    case home = "HOME"
    case permissions = "PERMISSIONS"
    
}
