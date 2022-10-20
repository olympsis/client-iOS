//
//  OlympsisApp.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import SwiftUI

@main
struct OlympsisApp: App {
    @AppStorage("token") var token:String? // auth token from server
    var body: some Scene {
        WindowGroup {
            if let _ = token {
                ViewContainer() // home view
            } else {
                //Auth() // auth view
                CreateAccount()
            }
        }
    }
}
