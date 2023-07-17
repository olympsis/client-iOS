//
//  Models.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/15/23.
//

import Foundation

struct Toast: Equatable {
    var style: ToastStyle
    var actor: String?
    var title: String
    var message: String
    var duration: Double = 3
    var width: Double = SCREEN_WIDTH
}

enum ToastStyle {
    case error
    case warning
    case success
    case info
    case newPost
    case message
    case newEvent
    case eventStatus
}
