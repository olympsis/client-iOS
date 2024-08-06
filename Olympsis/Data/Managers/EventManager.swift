//
//  EventManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/1/24.
//

import SwiftUI
import Foundation

class EventManager: ObservableObject {
    
    var event: Event
    
    init(event: Event) {
        self.event = event
    }
}
