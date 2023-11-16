//
//  ContentView.swift
//  OlympsisCompanion Watch App
//
//  Created by Joel on 10/14/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var selection: Int = 0
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            TabView(selection: $selection) {
                Workouts(selection: $selection).tag(0)
                InSession().tag(1)
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(SessionStore())
}
