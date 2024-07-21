//
//  SettingsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivitySettingsView: View {
    
    @AppStorage("unit_type") private var unitType: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Settings View")
                }
            }
        }
    }
}

#Preview {
    ActivitySettingsView()
}
