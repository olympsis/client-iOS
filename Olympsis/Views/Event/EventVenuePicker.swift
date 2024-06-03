//
//  EventVenuePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI

struct EventVenuePicker: View {
    
    @EnvironmentObject private var manager: NewEventManager
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    EventVenuePicker()
        .environmentObject(NewEventManager())
}
