//
//  Notifications.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/19/23.
//

import SwiftUI

struct Notifications: View {
    @State private var location = LocationObserver()
    @State private var notifications = NotificationsManager()
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Notifications_Previews: PreviewProvider {
    static var previews: some View {
        Notifications()
    }
}
