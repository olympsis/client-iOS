//
//  MessagesView.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/10/24.
//

import SwiftUI

struct HomeMessagesView: View {
    
    @State private var searchText: String = ""
    @Environment(HomeRouter.self) private var router
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Messages View")
                HStack {
                    Spacer()
                }
            }
        }
        .background(Color.Background.primary.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { router.navigateBack() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.Foreground.default)
                }
                .disabled(false)
            }
            
            ToolbarItem(placement: .principal) {
                Text("Messages")
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.Foreground.default)
                }
                
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(Color.Foreground.default)
                }
            }
        }
    }
}

struct SettingStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        Label(configuration)
            .labelStyle(.iconOnly)
            .foregroundStyle(Color.Foreground.default)
    }
}

#Preview {
    NavigationStack {
        HomeMessagesView()
            .environment(HomeRouter())
    }
}
