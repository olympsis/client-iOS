//
//  NotificationsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/18/23.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    Text("Hello, World!")
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{ self.presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("primary-color"))
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NotificationsView()
}
